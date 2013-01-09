class HomeController < FriendlyUrlController

  # -------------------------------------------------------------
  def index
    if @offerings.any?
      @not_started_assignments = []
      @started_assignments = []

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
      end

      respond_to do |format|
        format.html do
          render 'index'
        end
      end
    else
      not_found
    end
  end

end
