class ErrorsController < ApplicationController

  layout 'error'


  # -------------------------------------------------------------
  def error_404
    @not_found_path = params[:not_found]
  end

end
