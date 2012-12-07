class DepartmentsController < ApplicationController

  # -------------------------------------------------------------
  # GET /departments
  def index
    @institution = Institution.find(params[:institution_id])

    @departments = @institution?
      @institution.departments.all : Department.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @departments }
    end
  end


  # -------------------------------------------------------------
  # GET /departments/1
  def show
    @department = Department.find(params[:id])
    @institution = @department.institution

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @department }
    end
  end


  # -------------------------------------------------------------
  # GET /departments/new
  # GET /institution/:institution_id/departments/new
  def new
    @institution = Institution.find(params[:institution_id])

    @department = @institution ?
      @institution.departments.build : Department.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @department }
    end
  end


  # -------------------------------------------------------------
  # GET /departments/1/edit
  def edit
    @department = Department.find(params[:id])
    @institution = @department.institution
  end


  # -------------------------------------------------------------
  # POST /departments
  def create
    @department = Department.new(params[:department])
    @institution = @department.institution

    respond_to do |format|
      if @department.save
        format.html { redirect_to @department, notice: 'Department was successfully created.' }
        format.json { render json: @department, status: :created, location: @department }
      else
        format.html { render action: 'new' }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /departments/1
  def update
    @department = Department.find(params[:id])
    @institution = @department.institution

    respond_to do |format|
      if @department.update_attributes(params[:department])
        format.html { redirect_to @department, notice: 'Department was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /departments/1
  def destroy
    @department = Department.find(params[:id])
    @institution = @department.institution
    @department.destroy

    respond_to do |format|
      format.html { redirect_to institution_departments_url(@institution) }
      format.json { head :no_content }
    end
  end

end
