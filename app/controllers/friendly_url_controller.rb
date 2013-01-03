class FriendlyUrlController < ApplicationController

  before_filter :authenticate_user!
  before_filter :parse_path


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
