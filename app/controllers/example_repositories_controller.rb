class ExampleRepositoriesController < ApplicationController

  load_and_authorize_resource :course
  load_and_authorize_resource :example_repository,
    through: :course, shallow: true


  # -------------------------------------------------------------
  def index
  end


  # -------------------------------------------------------------
  def new
    respond_to do |format|
      format.js
      format.json { render json: @example_repository }
    end
  end


  # -------------------------------------------------------------
  def create
    @example_repository.user = current_user

    respond_to do |format|
      if @example_repository.save
        format.js
        format.html { redirect_to @example_repository, notice: 'Example repository was successfully created.' }
        format.json { render json: @example_repository, status: :created, location: @example_repository }
      else
        format.js
        format.html { render action: "new" }
        format.json { render json: @example_repository.errors, status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  def edit
  end


  # -------------------------------------------------------------
  def update
  end


  # -------------------------------------------------------------
  def destroy
  end

end
