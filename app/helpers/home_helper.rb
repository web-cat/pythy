module HomeHelper

  # -------------------------------------------------------------
  def course_exists?
    @term.exists? && @course
  end

end
