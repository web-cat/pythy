class AssignmentOfferingsController < ApplicationController
  # GET /assignment_offerings
  # GET /assignment_offerings.json
  def index
    @assignment_offerings = AssignmentOffering.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @assignment_offerings }
    end
  end

  # GET /assignment_offerings/1
  # GET /assignment_offerings/1.json
  def show
    @assignment_offering = AssignmentOffering.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @assignment_offering }
    end
  end

  # GET /assignment_offerings/new
  # GET /assignment_offerings/new.json
  def new
    @assignment_offering = AssignmentOffering.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @assignment_offering }
    end
  end

  # GET /assignment_offerings/1/edit
  def edit
    @assignment_offering = AssignmentOffering.find(params[:id])
  end

  # POST /assignment_offerings
  # POST /assignment_offerings.json
  def create
    @assignment_offering = AssignmentOffering.new(params[:assignment_offering])

    respond_to do |format|
      if @assignment_offering.save
        format.html { redirect_to @assignment_offering, :notice => 'Assignment offering was successfully created.' }
        format.json { render :json => @assignment_offering, :status => :created, :location => @assignment_offering }
      else
        format.html { render :action => "new" }
        format.json { render :json => @assignment_offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assignment_offerings/1
  # PUT /assignment_offerings/1.json
  def update
    @assignment_offering = AssignmentOffering.find(params[:id])

    respond_to do |format|
      if @assignment_offering.update_attributes(params[:assignment_offering])
        format.html { redirect_to @assignment_offering, :notice => 'Assignment offering was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @assignment_offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assignment_offerings/1
  # DELETE /assignment_offerings/1.json
  def destroy
    @assignment_offering = AssignmentOffering.find(params[:id])
    @assignment_offering.destroy

    respond_to do |format|
      format.html { redirect_to assignment_offerings_url }
      format.json { head :no_content }
    end
  end
end
