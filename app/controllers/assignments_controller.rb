class AssignmentsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :assignment
  load_resource :course, through: :assignment, shallow: true


  # -------------------------------------------------------------
  # GET /assignments
  # GET /assignments.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @assignments }
    end
  end


  # -------------------------------------------------------------
  # GET /assignments/1
  # GET /assignments/1.json
  def show
    @assignment_offerings =
      @assignment.assignment_offerings.joins(:course_offering).
        order('course_offerings.crn asc').select { |ao| can? :read, ao }

    @summary = @assignment.brief_summary_html
    @description = @assignment.description_html

    scores = []
    @score_summary = {
      minimum: 0.0,
      maximum: 0.0,
      median: 0.0,
      mean: 0.0
    }

    @assignment_offerings.each do |ao|
      ao.course_offering.users.each do |user|
        repository = ao.repository_for_user(user)

        if repository
          check = repository.assignment_checks.most_recent

          if check
            score = check.overall_score

            if score
              scores << score
              @score_summary[:maximum] = score if score > @score_summary[:maximum]
              @score_summary[:minimum] = score if score < @score_summary[:minimum]
            end
          end
        end
      end
    end

    if scores.length > 0
      scores.sort!
      @score_summary[:mean] = scores.inject(0.0) { |sum, el| sum + el } / scores.size
      @score_summary[:median] = median(scores)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @assignment }
      format.csv do
        @assignment_offerings.each { |ao| authorize! :edit, ao }
        render text: AssignmentOffering.to_csv(@assignment_offerings)
      end
    end
  end


  # -------------------------------------------------------------
  # GET /assignments/new
  # GET /assignments/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @assignment }
    end
  end


  # -------------------------------------------------------------
  # GET /assignments/1/edit
  def edit
    @assignment_offerings =
      @assignment.assignment_offerings.joins(:course_offering).
        order('course_offerings.crn asc').select { |ao| can? :manage, ao }
  end


  # -------------------------------------------------------------
  # POST /assignments
  # POST /assignments.json
  def create
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, :notice => 'Assignment was successfully created.' }
        format.json { render :json => @assignment, :status => :created, :location => @assignment }
      else
        format.html { render :action => "new" }
        format.json { render :json => @assignment.errors, :status => :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html { redirect_to @assignment, :notice => 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @assignment.errors, :status => :unprocessable_entity }
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to assignments_url }
      format.json { head :no_content }
    end
  end


  private

  # -------------------------------------------------------------
  def median(array)
    if array.length == 0
      0.0
    elsif array.length % 2 == 0
      (array[array.length / 2 - 1] + array[array.length / 2]) / 2
    else
      array[(array.length - 1) / 2]
    end
  end

end
