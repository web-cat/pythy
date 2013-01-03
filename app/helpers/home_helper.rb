module HomeHelper

  # -------------------------------------------------------------
  def course_exists?
    @institution && @term && @course
  end

end
