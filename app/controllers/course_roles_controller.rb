class CourseRolesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource


  # -------------------------------------------------------------
  # GET /course_roles
  # GET /course_roles.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @course_roles }
    end
  end


  # -------------------------------------------------------------
  # GET /course_roles/1
  # GET /course_roles/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course_role }
    end
  end


  # -------------------------------------------------------------
  # GET /course_roles/new
  # GET /course_roles/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course_role }
    end
  end


  # -------------------------------------------------------------
  # GET /course_roles/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /course_roles
  # POST /course_roles.json
  def create
    respond_to do |format|
      if @course_role.save
        format.html { redirect_to course_roles_url, notice: 'Course role was successfully created.' }
        format.json { render json: @course_role, status: :created, location: @course_role }
      else
        format.html { render action: "new" }
        format.json { render json: @course_role.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /course_roles/1
  # PUT /course_roles/1.json
  def update
    respond_to do |format|
      if @course_role.update_attributes(params[:course_role])
        format.html { redirect_to course_roles_url, notice: 'Course role was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course_role.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /course_roles/1
  # DELETE /course_roles/1.json
  def destroy
    respond_to do |format|
      if @course_role.destroy
        format.html { redirect_to course_roles_url, :notice => "Role deleted successfully" }
        format.json { head :no_content }
      else
        format.html { redirect_to course_roles_url, :notice => @course_role.errors[:base].to_s() }
        format.json { head :no_content }
      end
    end
  end

end
