class GlobalRolesController < ApplicationController
  # GET /global_roles
  # GET /global_roles.json
  def index
    @global_roles = GlobalRole.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @global_roles }
    end
  end

  # GET /global_roles/1
  # GET /global_roles/1.json
  def show
    @global_role = GlobalRole.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @global_role }
    end
  end

  # GET /global_roles/new
  # GET /global_roles/new.json
  def new
    @global_role = GlobalRole.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @global_role }
    end
  end

  # GET /global_roles/1/edit
  def edit
    @global_role = GlobalRole.find(params[:id])
  end

  # POST /global_roles
  # POST /global_roles.json
  def create
    @global_role = GlobalRole.new(params[:global_role])

    respond_to do |format|
      if @global_role.save
        format.html { redirect_to @global_role, notice: 'Global role was successfully created.' }
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
    @global_role = GlobalRole.find(params[:id])

    respond_to do |format|
      if @global_role.update_attributes(params[:global_role])
        format.html { redirect_to @global_role, notice: 'Global role was successfully updated.' }
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
    @global_role = GlobalRole.find(params[:id])
    @global_role.destroy

    respond_to do |format|
      format.html { redirect_to global_roles_url }
      format.json { head :no_content }
    end
  end
end
