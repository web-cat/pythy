class UsersController < ApplicationController

  load_and_authorize_resource

  # -------------------------------------------------------------
  # GET /users
  # GET /users.json
  def index
    @query = params[:query]
    @users = @users.search(@query).alphabetical.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json do
        if query
          emails = User.all_emails(query)
          render json: emails
        else
          render json: @users
        end
      end
    end
  end


  # -------------------------------------------------------------
  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end


  # -------------------------------------------------------------
  # GET /users/new
  # GET /users/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end


  # -------------------------------------------------------------
  # GET /users/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /users
  # POST /users.json
  def create
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end


  # -------------------------------------------------------------
  # GET /users/1/impersonate
  def impersonate
    if current_user
      session[:original_user] = current_user.id
      
      original_timestamp = @user.current_sign_in_at
      original_ip = @user.current_sign_in_ip

      sign_out :user if current_user 
      sign_in @user

      @user.current_sign_in_at = original_timestamp
      @user.current_sign_in_ip = original_ip
      @user.save
    end

    redirect_to root_path
  end


  # -------------------------------------------------------------
  # GET /users/unimpersonate
  def unimpersonate
    if session[:original_user]
      user = User.find(session[:original_user])
      session[:original_user] = nil

      sign_out :user if current_user 
      sign_in user
    end

    redirect_to root_path
  end

end
