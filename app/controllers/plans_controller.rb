class PlansController < ApplicationController
  before_action :set_plan, only: %i[ show edit update destroy ]
  before_action :require_admin!, except: %i[ index show ]

  # GET /plans
  def index
    @plans = if current_user&.is_admin?
      Plan.all
    else
      Plan.active
    end
  end

  # GET /plans/1
  def show
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    @llm_models = LlmModel.order(:name)
  end

  # GET /plans/1/edit
  def edit
    @llm_models = LlmModel.order(:name)
  end

  # POST /plans
  def create
    @plan = Plan.new(plan_params)

    if @plan.save
      redirect_to @plan, notice: "Plan was successfully created."
    else
      @llm_models = LlmModel.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plans/1
  def update
    if @plan.update(plan_params)
      redirect_to @plan, notice: "Plan was successfully updated."
    else
      @llm_models = LlmModel.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /plans/1
  def destroy
    @plan.destroy
    redirect_to plans_url, notice: "Plan was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find_by!(slug: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plan_params
      params.require(:plan).permit(:name, :price, :is_active, :description, llm_model_ids: [])
    end
end
