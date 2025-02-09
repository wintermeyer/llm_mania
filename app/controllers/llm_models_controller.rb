class LlmModelsController < ApplicationController
  before_action :set_llm_model, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[ index show ]
  load_and_authorize_resource

  # GET /llm_models
  def index
    @llm_models = if user_signed_in? && current_user.is_admin?
      LlmModel.order(:name)
    else
      LlmModel.where(is_active: true).order(:name)
    end
  end

  # GET /llm_models/1
  def show
  end

  # GET /llm_models/new
  def new
    @llm_model = LlmModel.new
  end

  # GET /llm_models/1/edit
  def edit
  end

  # POST /llm_models
  def create
    @llm_model = LlmModel.new(llm_model_params)

    if @llm_model.save
      redirect_to @llm_model, notice: "LLM model was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /llm_models/1
  def update
    Rails.logger.debug "Update params: #{llm_model_params.inspect}"
    if @llm_model.update(llm_model_params)
      redirect_to @llm_model, notice: "LLM model was successfully updated."
    else
      Rails.logger.debug "Validation errors: #{@llm_model.errors.full_messages}"
      Rails.logger.debug "Current attributes: #{@llm_model.attributes.inspect}"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /llm_models/1
  def destroy
    @llm_model.destroy!
    redirect_to llm_models_url, notice: "LLM model was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_llm_model
      @llm_model = LlmModel.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def llm_model_params
      params.require(:llm_model).permit(:name, :size, :is_active, :ollama_name)
    end
end
