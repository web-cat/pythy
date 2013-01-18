class AssignmentOfferingsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :course_offering
  load_and_authorize_resource :assignment_offering,
    through: :course_offering, shallow: true


  # -------------------------------------------------------------
  # GET /assignment_offerings
  # GET /assignment_offerings.json
  def index
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @assignment_offerings }
    end
  end


  # -------------------------------------------------------------
  # GET /assignment_offerings/1
  # GET /assignment_offerings/1.json
  def show
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @assignment_offering }
    end
  end


  # -------------------------------------------------------------
  # GET /assignment_offerings/new
  # GET /assignment_offerings/new.json
  def new
    @assignment = @assignment_offering.build_assignment

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @assignment_offering }
    end
  end


  # -------------------------------------------------------------
  # GET /assignment_offerings/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /assignment_offerings
  # POST /assignment_offerings.json
  def create
    @assignment = @assignment_offering.assignment
    @assignment.creator = current_user

    # Create in all offerings if checked.
    if params[:add_to_all_offerings]
      @assignment_offering.course_offering.other_concurrent_offerings.each do |offering|
        # FIXME This should be "can manage assignment offerings in offering"
        if can? :manage, offering
          new_assignment_offering = offering.assignment_offerings.build(
            params[:assignment_offering])
          new_assignment_offering.assignment = @assignment
          new_assignment_offering.save
        end
      end
    end

    respond_to do |format|
      if @assignment_offering.save
        format.html { redirect_to edit_assignment_path(@assignment) }
        format.js
        format.json { render json: @assignment_offering,
          status: :created, location: @assignment_offering }
      else
        format.js   { modal_form_errors @assignment_offering }
        format.html { render action: "new" }
        format.json { render json: @assignment_offering.errors,
          status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /assignment_offerings/1
  # PUT /assignment_offerings/1.json
  def update
    respond_to do |format|
      if @assignment_offering.update_attributes(params[:assignment_offering])
        format.html { redirect_to @assignment_offering,
          notice: 'Assignment offering was successfully updated.' }
        format.js
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assignment_offering.errors,
          status: :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /assignment_offerings/1
  # DELETE /assignment_offerings/1.json
  def destroy
    @assignment_offering.destroy

    respond_to do |format|
      format.html { redirect_to assignment_offerings_url }
      format.js
      format.json { head :no_content }
    end
  end
end
