class HomeController < ApplicationController
  
  before_filter :authenticate_user!

  # -------------------------------------------------------------
  def index
    #@institution = Term.from_path_component()
    @term = Term.from_path_component(params[:term])
    @course = Course.from_path_component(params[:course])

    puts @term
    puts @course

    respond_to do |format|
      format.html { render :index }
    end
  end

end
