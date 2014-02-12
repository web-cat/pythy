class FriendlyUrlController < ApplicationController

  before_filter :authenticate_user!
  before_filter :parse_path


  private

  # -------------------------------------------------------------
  def parse_path
    @organization = nil
    @course = nil
    @term = nil
    @offering = nil
    @offerings = []
    @rest = params[:rest]

    @organization = Organization.from_path_component(params[:organization]).first

    if @organization
      @course = Course.from_path_component(params[:course]).first

      if @course
        @term = Term.from_path_component(params[:term]).first

        if @term
          current_user.update_attributes(:current_course_id => @course.id, :current_term_id => @term.id)
          # TODO: I shouldn't be using the short label here.
          @offering = @course.course_offerings.where(:short_label => params[:offering]).first if params[:offering]
          #if cannot?(:show, @offering)
          #  forbidden
          #  return
          #end
          
          offerings = @course.offerings_for_user(current_user, @term)
          @offerings = offerings.select { |o| can?(:show, o) }
        else
          not_found
          return
        end
      end
    else
      # TODO: this is scratchpad.
      # Put the rest of the path together again.
      parts = []
      parts << params[:organization] if params[:organization]
      parts << params[:course] if params[:course]
      parts << params[:term] if params[:term]
      parts << params[:offering] if params[:offering]
      parts << params[:rest] if params[:rest]
      @rest = parts.empty? ? nil : File.join(parts)
    end
  end

end
