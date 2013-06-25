class ExampleRepositoriesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :course_offering
  load_and_authorize_resource :example_repository,
    through: :course_offering, shallow: true


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

    # Create the dependent repositories as well.
    # TODO Handle errors when saving linked repos.
    if params[:add_to_all_offerings]
      @example_repository.course_offering.other_concurrent_offerings.each do |offering|
        if can? :manage, offering
          linked_repository = @example_repository.linked_repositories.build(
            params[:example_repository])
          linked_repository.course_offering = offering
          linked_repository.user = @example_repository.user
          linked_repository.save
        end
      end
    end

    respond_to do |format|
      if @example_repository.save
        Juggernaut.publish @example_repository.course_offering.event_channel('examples'),
          {}, except: request.headers['X-Session-ID']

        format.js
        format.html { redirect_to @example_repository, notice: 'Example repository was successfully created.' }
        format.json { render json: @example_repository, status: :created, location: @example_repository }
      else
        format.js   { modal_form_errors @example_repository }
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
    offering = @example_repository.course_offering
    @example_repository.destroy

    Juggernaut.publish offering.event_channel('examples'),
      {}, except: request.headers['X-Session-ID']

    respond_to do |format|
      format.html { redirect_to view_context.home_path(offering) }
      format.json { head :no_content }
    end
  end

end
