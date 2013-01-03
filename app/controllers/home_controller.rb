class HomeController < ApplicationController
  
  before_filter :authenticate_user!


  # -------------------------------------------------------------
  def index
    parse_path

    if @offerings.any?
      respond_to do |format|
        format.html do
          render 'index'
        end
      end
    else
      not_found
    end
  end


  private

  # -------------------------------------------------------------
  def parse_path
    @institution = Institution.from_path_component(params[:institution]).first
    @term = Term.from_path_component(params[:term]).first

    if @institution && @term
      @course = Course.from_path_component(params[:course], @institution).first
    end

    @offerings = []

    if @course
      if params[:crn]
        offering = @course.offering_with_crn(params[:crn], @term)
        @offerings << offering if can?(:show, offering)
      else
        offerings = @course.offerings_for_user(current_user, @term)
        @offerings = offerings.select { |o| can?(:show, o) }
      end
    end
  end

end
