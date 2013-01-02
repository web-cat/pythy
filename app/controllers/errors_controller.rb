class ErrorsController < ApplicationController

  layout 'plain'


  # -------------------------------------------------------------
  def error_404
    @not_found_path = params[:not_found]
  end

end
