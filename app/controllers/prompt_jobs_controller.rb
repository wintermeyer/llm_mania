class PromptJobsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /prompt_jobs or /prompt_jobs.json
  def index
    @prompt_jobs = current_user.prompt_jobs.order(created_at: :desc)
  end

  # GET /prompt_jobs/1 or /prompt_jobs/1.json
  def show
  end

  # GET /prompt_jobs/new
  def new
    @prompt_job = current_user.prompt_jobs.build
  end

  # POST /prompt_jobs or /prompt_jobs.json
  def create
    @prompt_job = current_user.prompt_jobs.build(prompt_job_params)

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

  # DELETE /prompt_jobs/1 or /prompt_jobs/1.json
  def destroy
    @prompt_job.destroy!

    respond_to do |format|
      format.html { redirect_to prompt_jobs_path, status: :see_other, notice: "Prompt job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def prompt_job_params
    params.require(:prompt_job).permit(:prompt)
  end
end
