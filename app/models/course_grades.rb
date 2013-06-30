class CourseGrades

  # -------------------------------------------------------------
  def initialize(course_offering)
    @course_offering = course_offering
    @users = @course_offering.users_sorted_by_role
    @assignment_offerings = @course_offering.assignment_offerings

    @user_grades = []
    @user_indices = {}

    @users.each do |user|
      grades = []

      @assignment_offerings.each do |assignment_offering|
        repository = assignment_offering.repository_for_user(user)

        if repository && repository.assignment_checks.any?
          most_recent = repository.assignment_checks.most_recent
          grades << most_recent.overall_score
        else
          grades << nil
        end
      end

      @user_indices[user] = @user_grades.length
      @user_grades << grades
    end
  end


  # -------------------------------------------------------------
  def assignment_offerings
    @assignment_offerings
  end


  # -------------------------------------------------------------
  def users
    @users
  end


  # -------------------------------------------------------------
  def grades_for_user(user)
    @user_grades[@user_indices[user]]
  end

end
