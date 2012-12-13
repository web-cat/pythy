class GlobalRolesController < ApplicationController
  load_and_authorize_resource
  # GET /global_roles
  # GET /global_roles.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @global_roles }
    end
  end

  # GET /global_roles/1
  # GET /global_roles/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @global_role }
    end
  end

  # GET /global_roles/new
  # GET /global_roles/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @global_role }
    end
  end

  # GET /global_roles/1/edit
  def edit
  end

  # POST /global_roles
  # POST /global_roles.json
  def create
    respond_to do |format|
      if @global_role.save
        format.html { redirect_to global_roles_url, notice: 'Global role was successfully created.' }
        format.json { render json: @global_role, status: :created, location: @global_role }
      else
        format.html { render action: "new" }
        format.json { render json: @global_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /global_roles/1
  # PUT /global_roles/1.json
  def update
    respond_to do |format|
      if @global_role.update_attributes(params[:global_role])
        format.html { redirect_to global_roles_url, notice: 'Global role was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @global_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /global_roles/1
  # DELETE /global_roles/1.json
  def destroy
    respond_to do |format|
      if @global_role.destroy
        format.html { redirect_to global_roles_url, :notice => "Role deleted successfully" }
        format.json { head :no_content }
      else
        format.html { redirect_to global_roles_url, :notice => @global_role.errors[:base].to_s() }
        format.json { head :no_content }
      end
    end
  end
end
