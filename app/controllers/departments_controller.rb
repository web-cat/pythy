class DepartmentsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :institution
  load_and_authorize_resource :department,
    through: :institution, shallow: true


  # -------------------------------------------------------------
  # GET /departments
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @departments }
    end
  end


  # -------------------------------------------------------------
  # GET /departments/1
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @department }
    end
  end


  # -------------------------------------------------------------
  # GET /departments/new
  # GET /institution/:institution_id/departments/new
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @department }
    end
  end


  # -------------------------------------------------------------
  # GET /departments/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /departments
  def create
    respond_to do |format|
      if @department.save
        format.html { redirect_to @department,
          notice: 'Department was successfully created.' }
        format.json { render json: @department,
          status: :created, location: @department }
      else
        format.html { render action: 'new' }
        format.json { render json: @department.errors,
          status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /departments/1
  def update
    respond_to do |format|
      if @department.update_attributes(params[:department])
        format.html { redirect_to @department,
          notice: 'Department was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @department.errors,
          status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /departments/1
  def destroy
    @department.destroy

    respond_to do |format|
      format.html { redirect_to
        institution_departments_url(@department.institution) }
      format.json { head :no_content }
    end
  end

end
