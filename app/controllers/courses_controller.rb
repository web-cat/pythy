class CoursesController < ApplicationController

  load_and_authorize_resource :department
  load_and_authorize_resource :course,
    through: :department, shallow: true

  # -------------------------------------------------------------
  # GET /courses
  # GET /courses.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @courses }
    end
  end


  # -------------------------------------------------------------
  # GET /courses/1
  # GET /courses/1.json
  def show
    @grouped_offerings = @course.course_offerings.group_by(&:term)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course }
    end
  end


  # -------------------------------------------------------------
  # GET /courses/new
  # GET /courses/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end


  # -------------------------------------------------------------
  # GET /courses/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /courses
  # POST /courses.json
  def create
    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /courses/1
  # PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy

    respond_to do |format|
      format.html { redirect_to department_courses_url(@course.department) }
      format.json { head :no_content }
    end
  end

end
