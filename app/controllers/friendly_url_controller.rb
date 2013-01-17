class FriendlyUrlController < ApplicationController

  before_filter :authenticate_user!
  before_filter :parse_path


  private

  # -------------------------------------------------------------
  def parse_path
    @institution = nil
    @course = nil
    @offerings = []
    @rest = params[:rest]

    @institution = Institution.from_path_component(params[:institution]).first

    if @institution
      @term = Term.from_path_component(params[:term]).first

      if @term
        @course = Course.from_path_component(params[:course], @institution).first

        if @course
          if params[:crn]
            offering = @course.offering_with_crn(params[:crn], @term)
            @offerings << offering if can?(:show, offering)
          else
            offerings = @course.offerings_for_user(current_user, @term)
            @offerings = offerings.select { |o| can?(:show, o) }
          end
        end
      else
        # The "term" part might actually be a course if there is no term,
        # so try that.
        @course = Course.from_path_component(params[:term], @institution).first

        if @course
          # Put the rest of the path together again.
          parts = []
          parts << params[:course] if params[:course]
          parts << params[:crn] if params[:crn]
          parts << params[:rest] if params[:rest]
          @rest = parts.empty? ? nil : File.join(parts)
        end
      end
    end
  end

end
