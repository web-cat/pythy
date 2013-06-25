class HomeController < FriendlyUrlController

  layout 'no_container'
  before_filter :authenticate_user!

  # -------------------------------------------------------------
  def index
    command = params[:command]

    @organization_list = Organization.all.map { |o| [o.display_name, o.id] }

    if @offerings.any?
      @not_started_assignments = []
      @started_assignments = []
      @assignments = []
      @examples = []

      # FIXME This isn't right, but I'm not sure yet how to ask Cancan whether
      # the current ability can create new assignment offerings for a course
      # offering.
      staff = @offerings.first.role_for_user(
        current_user).staff?

      @offerings.each do |offering|
        @examples |= offering.example_repositories.where(
          source_repository_id: nil)

        if staff
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
      @not_started_assignments.sort! { |a, b|
        if a.effectively_due_at.nil? && b.effectively_due_at.nil?
          0
        elsif b.effectively_due_at.nil?
          1
        elsif a.effectively_due_at.nil?
          -1
        else
          b.effectively_due_at <=> a.effectively_due_at
        end
      }

      respond_to do |format|
        format.html { render staff ? 'index_staff' : 'index' }
        format.js { render command }
      end
    else
      offerings = current_user.course_offerings
      @courses = offerings.group_by { |co| co.course }

      if offerings.count == 0
        respond_to do |format|
          format.html do
            render 'index_no_courses'
          end
        end
      elsif offerings.count == 1
        respond_to do |format|
          format.html do
            render 'index_no_courses'
          end
        end
      else        
        respond_to do |format|
          format.html do
            render 'index_no_courses'
          end
        end
      end
    end
  end

end
