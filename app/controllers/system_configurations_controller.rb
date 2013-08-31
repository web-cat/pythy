class SystemConfigurationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_and_authorize_system_configuration


  # -------------------------------------------------------------
  # GET /system_configuration
  # GET /system_configuration.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @system_configuration }
    end
  end


  # -------------------------------------------------------------
  # GET /system_configuration/new
  # GET /system_configuration/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @system_configuration }
    end
  end


  # -------------------------------------------------------------
  # GET /system_configuration/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /system_configuration
  # POST /system_configuration.json
  def create
    respond_to do |format|
      if @system_configuration.update_attributes(params[:system_configuration])
        format.html do
          redirect_to root_path,
            notice: 'System configuration was successfully created.'
        end
        format.json { render json: @system_configuration, status: :created, location: @system_configuration }
      else
        format.html { render action: "new" }
        format.json { render json: @system_configuration.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /system_configuration
  # PUT /system_configuration.json
  def update
    respond_to do |format|
      if @system_configuration.update_attributes(params[:system_configuration])
        format.html do
          redirect_to root_path,
            notice: 'System configuration was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @system_configuration.errors, status: :unprocessable_entity }
      end
    end
  end


  private

  # -------------------------------------------------------------
  def load_and_authorize_system_configuration
    @system_configuration =
      SystemConfiguration.first || SystemConfiguration.new
    authorize! :edit, @system_configuration
  end

end
