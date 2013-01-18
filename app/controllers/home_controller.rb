class HomeController < FriendlyUrlController

  # -------------------------------------------------------------
  def index
    if @offerings.any?
      @not_started_assignments = []
      @started_assignments = []
      @examples = []

      @offerings.each do |offering|
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

        @examples |= offering.example_repositories.all
      end

      @examples.sort! { |a, b| b.created_at <=> a.created_at }
      @started_assignments.sort! { |a, b| a.updated_at <=> b.updated_at }
      @not_started_assignments.sort! { |a, b| b.effectively_due_at <=> a.effectively_due_at }

      respond_to do |format|
        format.html do
          render 'index'
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
            redirect_to view_context.course_offering_home_path(offerings.first)
          end
        end
      else        
        not_found
      end
    end
  end

end
