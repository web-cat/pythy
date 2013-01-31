class AssignmentChecksController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :assignment_repository
  load_and_authorize_resource :assignment_check,
    through: :assignment_repository, shallow: true


  # -------------------------------------------------------------
  def index
    # FIXME Why do I have to do this? The l_a_a_r above should take
    # care of it.
    @assignment_checks = @assignment_repository.assignment_checks

    @scores = []
    @check_ids = []
    @assignment_checks.each do |check|
      @scores << [
        check.number,
        (check.overall_score / 100).to_f,
        "<div style='padding: 2px 5px'><b>Attempt #{check.number}:</b><br/>#{check.overall_score.round}%</div>"
      ]
      @check_ids << check.id
    end

    respond_to do |format|
      format.js
    end
  end


  # -------------------------------------------------------------
  def show
    respond_to do |format|
      format.js
    end
  end

end
