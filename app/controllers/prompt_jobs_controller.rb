class PromptJobsController < ApplicationController
  before_action :set_prompt_job, only: %i[ show edit update destroy ]

  # GET /prompt_jobs or /prompt_jobs.json
  def index
    @prompt_jobs = PromptJob.all
  end

  # GET /prompt_jobs/1 or /prompt_jobs/1.json
  def show
  end

  # GET /prompt_jobs/new
  def new
    @prompt_job = PromptJob.new
  end

  # GET /prompt_jobs/1/edit
  def edit
  end

  # POST /prompt_jobs or /prompt_jobs.json
  def create
    @prompt_job = PromptJob.new(prompt_job_params)

    respond_to do |format|
      if @prompt_job.save
        format.html { redirect_to @prompt_job, notice: "Prompt job was successfully created." }
        format.json { render :show, status: :created, location: @prompt_job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @prompt_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prompt_jobs/1 or /prompt_jobs/1.json
  def update
    respond_to do |format|
      if @prompt_job.update(prompt_job_params)
        format.html { redirect_to @prompt_job, notice: "Prompt job was successfully updated." }
        format.json { render :show, status: :ok, location: @prompt_job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @prompt_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prompt_jobs/1 or /prompt_jobs/1.json
  def destroy
    @prompt_job.destroy!

    respond_to do |format|
      format.html { redirect_to prompt_jobs_path, status: :see_other, notice: "Prompt job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prompt_job
      @prompt_job = PromptJob.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def prompt_job_params
      params.expect(prompt_job: [ :prompt, :user_id ])
    end
end
