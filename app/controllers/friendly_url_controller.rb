class FriendlyUrlController < ApplicationController

  before_filter :authenticate_user!
  before_filter :parse_path


  private

  # -------------------------------------------------------------
  def parse_path
    @organization = nil
    @course = nil
    @term = nil
    @offerings = []
    @rest = params[:rest]

    @organization = Organization.from_path_component(params[:organization]).first

    if @organization
      @course = Course.from_path_component(params[:course]).first

      if @course
        @term = Term.from_path_component(params[:term]).first

        if @term
          offerings = @course.offerings_for_user(current_user, @term)
          @offerings = offerings.select { |o| can?(:show, o) }          
        else
          # Put the rest of the path together again.
          parts = []
          parts << params[:term] if params[:term]
          parts << params[:offering] if params[:offering]
          parts << params[:rest] if params[:rest]
          @rest = parts.empty? ? nil : File.join(parts)
        end
      end
    else
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
