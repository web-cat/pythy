class AssignmentsController < ApplicationController

  before_filter :authenticate_user!

  load_and_authorize_resource :assignment
  load_resource :course, through: :assignment, shallow: true

  before_filter :get_assignment_offerings,
    only: [ :show, :edit, :create, :update ]

  before_filter :get_course_and_term,
    only: [ :show, :edit, :create, :update ]

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
    @summary = @assignment.brief_summary_html
    @description = @assignment.description_html
    
    relation = AssignmentReferenceRepository.where(
      assignment_id: @assignment.id)

    # Create the repository if it doesn't exist.
    # TODO improve permission checks
    @repository = relation.first

    if @repository.nil? && can?(:edit, assignment)
      @repository = relation.create(user_id: current_user.id)
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
        format.html { render :action => 'new' }
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
        format.html { render :action => 'edit' }
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
  
  
  # Regrade every student's submission for this assignment
  def regrade_all
    if !params[:offering_id]
      not_found
      return
    end
    
    @assignment_offering = @assignment.assignment_offerings.where(:course_offering_id => params[:offering_id].to_i).first
    
    # TODO: Is this the correct authorization?
    authorize! :manage, @assignment_offering
    
    @assignment_offering.assignment_repositories.each do |repo|
      assignment_check = repo.assignment_checks.create(number: repo.next_assignment_check_number)

      CheckCodeWorker.perform_async(assignment_check.id, request.headers['X-Session-ID'])
    end
    
    redirect_to assignment_path(@assignment, anchor: 'grades')
  end
  
  
  # Regrade this assignment repository
  def regrade
    if !params[:offering_id] || !params[:repository_id]
      not_found
      return
    end
    
    @assignment_offering = @assignment.assignment_offerings.where(:course_offering_id => params[:offering_id].to_i).first
    
    @repository = @assignment_offering.assignment_repositories.where(:id => params[:repository_id].to_i).first
    
    authorize! :manage, @assignment_offering

    assignment_check = @repository.assignment_checks.create(number: @repository.next_assignment_check_number)

    CheckCodeWorker.perform_async(assignment_check.id, request.headers['X-Session-ID'])
    
    redirect_to assignment_path(@assignment, anchor: 'grades')
  end
  
  
  def template_picker

    @course = Course.from_path_component(params[:course]).first    
    authorize! :manage, @course

    @term = Term.from_path_component(params[:term]).first
    
    @assignments = @course.assignments.select{ |o| can?(:show, o) }
    
    @assignments = Kaminari.paginate_array(@assignments).page(params[:page]).per(25)
  end
  
  
  def pick_template
    
    @course = Course.from_path_component(params[:course]).first    
    authorize! :manage, @course

    @term = Term.from_path_component(params[:term]).first
    
    template = Assignment.find(params[:template_id])    
    authorize! :show, template
    
    @assignment = Assignment.new
    @assignment.creator = current_user
    @assignment.course = @course
    @assignment.term = @term
    @assignment.short_name = template.short_name
    @assignment.long_name = template.long_name
    @assignment.brief_summary = template.brief_summary
    @assignment.description = template.description
    @assignment.set_url_part
    
    @assignment.save!
    
    # Create in all offerings.
    course_offerings = CourseOffering.where(:course_id => @course.id, :term_id => @term.id)
    
    course_offerings.each do |offering|
      # FIXME This should be "can manage assignment offerings in offering"
      if can? :manage, offering
        new_assignment_offering = offering.assignment_offerings.build(
          params[:assignment_offering])
        new_assignment_offering.assignment = @assignment
        new_assignment_offering.save
      end
    end
    
    redirect_to edit_assignment_path(@assignment)
  end


  private

  # -------------------------------------------------------------
  def get_assignment_offerings
    @assignment_offerings =
      @assignment.assignment_offerings.joins(:course_offering).
        order('course_offerings.short_label asc').select { |ao| can? :read, ao }
  end
  
  def get_course_and_term    
    @term = @assignment.term
    @course = @assignment.course
  end

end
