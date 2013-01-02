class CourseOfferingsController < ApplicationController

  load_and_authorize_resource :course
  load_and_authorize_resource :course_offering,
    through: :course, shallow: true


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # GET /course_offerings
  # GET /course_offerings.json
  def index
    @grouped_offerings = @course_offerings.group_by(&:term)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @course_offerings }
    end
  end


  # -------------------------------------------------------------
  # GET /course_offerings/1
  # GET /course_offerings/1.json
  def show
    @course_enrollments = @course_offering.course_enrollments.page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render :json => @course_offering }
    end
  end


  # -------------------------------------------------------------
  # GET /course_offerings/new
  # GET /course_offerings/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @course_offering }
    end
  end


  # -------------------------------------------------------------
  # GET /course_offerings/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /course_offerings
  # POST /course_offerings.json
  def create
    respond_to do |format|
      if @course_offering.save
        format.html { redirect_to @course_offering, :notice => 'Course offering was successfully created.' }
        format.json { render :json => @course_offering, :status => :created, :location => @course_offering }
      else
        format.html { render :action => "new" }
        format.json { render :json => @course_offering.errors, :status => :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /course_offerings/1
  # PUT /course_offerings/1.json
  def update
    @course_offering = CourseOffering.find(params[:id])

    respond_to do |format|
      if @course_offering.update_attributes(params[:course_offering])
        format.html { redirect_to @course_offering, :notice => 'Course offering was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @course_offering.errors, :status => :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /course_offerings/1
  # DELETE /course_offerings/1.json
  def destroy
    @course_offering.destroy

    respond_to do |format|
      format.html { redirect_to course_offerings_url(@course_offering.course) }
      format.json { head :no_content }
    end
  end

end
