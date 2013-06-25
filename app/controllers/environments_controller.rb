class EnvironmentsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # GET /environments
  # GET /environments.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @environments }
    end
  end


  # -------------------------------------------------------------
  # GET /environments/1
  # GET /environments/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @environment }
    end
  end


  # -------------------------------------------------------------
  # GET /environments/new
  # GET /environments/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @environment }
    end
  end


  # -------------------------------------------------------------
  # GET /environments/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /environments
  # POST /environments.json
  def create
    respond_to do |format|
      if @environment.save
        format.html { redirect_to @environment, notice: 'Environment was successfully created.' }
        format.json { render json: @environment, status: :created, location: @environment }
      else
        format.html { render action: "new" }
        format.json { render json: @environment.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /environments/1
  # PUT /environments/1.json
  def update
    respond_to do |format|
      if @environment.update_attributes(params[:environment])
        format.html { redirect_to @environment, notice: 'Environment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @environment.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /environments/1
  # DELETE /environments/1.json
  def destroy
    @environment.destroy

    respond_to do |format|
      format.html { redirect_to environments_url }
      format.json { head :no_content }
    end
  end
end
