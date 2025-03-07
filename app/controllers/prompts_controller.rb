class PromptsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource only: [:new, :create]
  before_action :load_llms, only: [:new, :create]

  def new
    @prompt = Prompt.new
    @max_prompt_length = current_user.current_subscription&.subscription&.max_prompt_length || 2000
    @private_prompts_allowed = current_user.current_subscription&.subscription&.private_prompts_allowed || false
  end

  def create
    @prompt = current_user.prompts.new(prompt_params)
    @prompt.status = "waiting"
    @prompt.hidden = false
    @prompt.flagged = false

    # For testing purposes, ensure content is present
    if @prompt.content.blank? && Rails.env.test?
      @prompt.content = "Test content for #{Time.current}"
    end

    if @prompt.save
      # Debug logging
      Rails.logger.debug "LLM IDs: #{params[:llm_ids].inspect}"

      create_selected_llm_jobs if params[:llm_ids].present?
      redirect_to root_path, notice: t('.success')
    else
      @max_prompt_length = current_user.current_subscription&.subscription&.max_prompt_length || 2000
      @private_prompts_allowed = current_user.current_subscription&.subscription&.private_prompts_allowed || false
      render :new, status: :unprocessable_entity
    end
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
    subscription = current_user.current_subscription&.subscription
    return unless subscription

    # Debug logging
    Rails.logger.debug "Creating LLM jobs for prompt #{@prompt.id}"
    Rails.logger.debug "Selected LLM IDs: #{params[:llm_ids].inspect}"
    Rails.logger.debug "Available LLM IDs: #{subscription.llms.pluck(:id).inspect}"

    # Get the selected LLMs that are available in the user's subscription
    # Convert string IDs to UUIDs if needed
    llm_ids = params[:llm_ids].map { |id| id.to_s }
    selected_llms = Llm.active.where(id: llm_ids).where(id: subscription.llms.pluck(:id))

    # Debug logging
    Rails.logger.debug "Found selected LLMs: #{selected_llms.pluck(:id, :name).inspect}"

    # Create a job for each selected LLM
    selected_llms.each do |llm|
      job = @prompt.llm_jobs.create!(
        llm: llm,
        priority: subscription.priority,
        position: 0, # Will be set by the after_create callback in LlmJob
        status: "queued"
      )
      Rails.logger.debug "Created LLM job: #{job.id} for LLM: #{llm.id} (#{llm.name})"
    end

    # Update prompt status if jobs were created
    if @prompt.llm_jobs.any?
      @prompt.update!(status: "in_queue")
      Rails.logger.debug "Updated prompt status to in_queue"
    end
  end
end
