class AssignmentChecksController < ApplicationController

  load_and_authorize_resource :assignment_check

  def show
    respond_to do |format|
      format.js
    end
  end

end
