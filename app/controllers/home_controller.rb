class HomeController < FriendlyUrlController

  before_filter :authenticate_user!

  # -------------------------------------------------------------
  def index
    if @offerings.any?
      @not_started_assignments = []
      @started_assignments = []
      @assignments = []
      @examples = []

      # FIXME This isn't right, but I'm not sure yet how to ask Cancan whether
      # the current ability can create new assignment offerings for a course
      # offering.
      instructor = @offerings.first.role_for_user(
        current_user).try(:can_manage_assignments?)

      @offerings.each do |offering|
        @examples |= offering.example_repositories.where(
          source_repository_id: nil)

        if instructor
          assignments = offering.assignment_offerings
          @assignments |= assignments.map { |ao| ao.assignment }
        else
          assignments = offering.assignment_offerings.visible
          assignments.each do |assignment|
            # TODO does a repository exist for the student and assignment? Put
            # it in the right bucket.

            repo = AssignmentRepository.where(
              assignment_offering_id: assignment.id,
              user_id: current_user.id).first

            if repo
              @started_assignments |= [assignment]
            else
              @not_started_assignments |= [assignment]
            end
          end
        end
      end

      @examples.sort! { |a, b| b.created_at <=> a.created_at }
      @assignments.sort! { |a, b| a.updated_at <=> b.updated_at }
      @started_assignments.sort! { |a, b| a.updated_at <=> b.updated_at }
      @not_started_assignments.sort! { |a, b| b.effectively_due_at <=> a.effectively_due_at }

      respond_to do |format|
        format.html do
          render instructor ? 'index_instructor' : 'index'
        end
      end
    else
      offerings = current_user.course_offerings

      if offerings.count == 0
        respond_to do |format|
          format.html do
            render 'index_no_courses'
          end
        end
      elsif offerings.count == 1
        respond_to do |format|
          format.html do
            redirect_to view_context.home_path(offerings.first)
          end
        end
      else        
        respond_to do |format|
          format.html do
            render 'index_many_courses'
          end
        end
      end
    end
  end

end
