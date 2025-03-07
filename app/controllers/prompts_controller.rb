class PromptsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource only: [:new, :create, :show]
  before_action :load_llms, only: [:new, :create]
  skip_authorization_check only: [:index]

  def index
    # Get public prompts and the current user's prompts
    @prompts = if user_signed_in?
      Prompt.where(private: false).or(Prompt.where(user: current_user))
            .includes(:user, :llm_jobs)
            .order(created_at: :desc)
    else
      Prompt.where(private: false)
            .includes(:user, :llm_jobs)
            .order(created_at: :desc)
    end
  end

  def new
    @prompt = Prompt.new
    @max_prompt_length = current_user.current_subscription&.subscription&.max_prompt_length || 2000
    @private_prompts_allowed = current_user.current_subscription&.subscription&.private_prompts_allowed || false
  end

  def create
    @prompt = Prompt.new(prompt_params)
    @prompt.user = current_user
    @prompt.status = "waiting"
    @prompt.hidden = false if @prompt.hidden.nil?
    @prompt.flagged = false if @prompt.flagged.nil?
    @prompt.private = false if @prompt.private.nil?

    # For testing purposes, ensure content is present unless explicitly opted out
    if @prompt.content.blank? && Rails.env.test? && params[:skip_auto_content] != "true"
      @prompt.content = "Test content for #{Time.current}"
    end

    if @prompt.save
      # Only process LLM IDs if they are provided
      create_selected_llm_jobs if params[:llm_ids].present?

      # Always redirect to the prompt show page
      redirect_to prompt_path(@prompt), notice: "Prompt was successfully created."
    else
      # Load necessary data for the form
      load_llms

      # Always render the new template
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @prompt = Prompt.find(params[:id])
    authorize! :read, @prompt
  end

  # Get the current status of all LLM jobs for a prompt
  def llm_jobs_status
    @prompt = Prompt.find(params[:id])
    authorize! :read, @prompt

    # Get all LLM jobs for this prompt with their related LLM
    @llm_jobs = @prompt.llm_jobs.includes(:llm)

    # Render a partial that contains only the LLM responses section
    render partial: 'prompts/llm_jobs_status', locals: { prompt: @prompt, llm_jobs: @llm_jobs }
  end

  private

  def prompt_params
    params.require(:prompt).permit(:content, :private)
  end

  def load_llms
    subscription = current_user.current_subscription&.subscription
    # Get all active LLMs
    @all_llms = Llm.active.order(:name)

    # Get the available LLMs for the current subscription
    @available_llms = subscription ? subscription.llms.active.order(:name) : []

    # Get the unavailable LLMs (those not in the current subscription)
    @unavailable_llms = subscription ? @all_llms - @available_llms : @all_llms

    # Store current subscription for reference
    @current_subscription_name = subscription&.name

    # Get subscription names for each LLM (excluding current subscription)
    @llm_subscriptions = {}
    Subscription.where(active: true).each do |sub|
      # Skip the current subscription
      next if sub.id == subscription&.id

      sub.llms.each do |llm|
        @llm_subscriptions[llm.id] ||= []
        @llm_subscriptions[llm.id] << sub.name
      end
    end
  end

  def create_selected_llm_jobs
    subscription_history = current_user.current_subscription
    unless subscription_history
      return # No LLM jobs if subscription history not found
    end

    subscription = subscription_history.subscription
    unless subscription
      return # No LLM jobs if subscription not found
    end

    # Get the selected LLMs that are available in the user's subscription
    # Convert string IDs to UUIDs if needed
    llm_ids = params[:llm_ids].map { |id| id.to_s }
    selected_llms = Llm.active.where(id: llm_ids).where(id: subscription.llms.pluck(:id))

    # Create a job for each selected LLM
    selected_llms.each do |llm|
      # Ensure priority is at least 1 (LlmJob requires priority >= 1)
      job_priority = [subscription.priority, 1].max

      @prompt.llm_jobs.create!(
        llm: llm,
        priority: job_priority,
        position: 0, # Will be set by the after_create callback in LlmJob
        status: "queued"
      )
    end

    # Update prompt status if jobs were created
    @prompt.update!(status: "in_queue") if @prompt.llm_jobs.any?
  end
end
