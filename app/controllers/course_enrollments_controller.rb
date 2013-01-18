class CourseEnrollmentsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :course_offering
  load_and_authorize_resource :course_enrollment,
    through: :course_offering, shallow: true

  rescue_from 'ActiveRecord::RecordNotUnique' do |exception|
    flash[:error] = "The user #{@course_enrollment.user.display_name} already has that role in the course."
    render template: 'application/place_flash',
      locals: { where: '#flashbar-placeholder' }
  end


  # -------------------------------------------------------------
  # GET /course_enrollments
  # GET /course_enrollments.json
  def index
    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @course_enrollments }
    end
  end


  # -------------------------------------------------------------
  # GET /course_enrollments/1
  # GET /course_enrollments/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course_enrollment }
    end
  end


  # -------------------------------------------------------------
  # GET /course_enrollments/new
  # GET /course_enrollments/new.json
  def new
    respond_to do |format|
      format.js
      format.json { render json: @course_enrollment }
    end
  end


  # -------------------------------------------------------------
  # GET /course_enrollments/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /course_enrollments
  # POST /course_enrollments.json
  def create
    respond_to do |format|
      if @course_enrollment.save
        format.js
        format.html { redirect_to @course_enrollment, notice: 'Course enrollment was successfully created.' }
        format.json { render json: @course_enrollment, status: :created, location: @course_enrollment }
      else
        format.js
        format.html { render action: "new" }
        format.json { render json: @course_enrollment.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /course_enrollments/1
  # PUT /course_enrollments/1.json
  def update
    respond_to do |format|
      if @course_enrollment.update_attributes(params[:course_enrollment])
        format.js
        format.html { redirect_to @course_enrollment, notice: 'Course enrollment was successfully updated.' }
        format.json { head :no_content }
      else
        format.js
        format.html { render action: "edit" }
        format.json { render json: @course_enrollment.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /course_enrollments/1
  # DELETE /course_enrollments/1.json
  def destroy
    @course_enrollment.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to course_enrollments_url }
      format.json { head :no_content }
    end
  end

end
