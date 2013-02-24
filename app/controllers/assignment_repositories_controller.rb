class AssignmentRepositoriesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :assignment_repository


  # -------------------------------------------------------------
  def show
    #@assignment_checks = @assignment_repository.assignment_checks
    @assignment_offering = @assignment_repository.assignment_offering
    @assignment = @assignment_offering.assignment

    respond_to do |format|
      format.html
      format.json do
        # TODO Handle assignments that are open forever, or never open
        if @assignment_offering.opens_at && @assignment_offering.effectively_due_at
          collector = CommitCollector.new(@assignment_repository,
            @assignment_offering.opens_at, @assignment_offering.effectively_due_at, 1)
          buckets = collector.commit_time_data
        end

        render json: buckets
      end
    end
  end

end
