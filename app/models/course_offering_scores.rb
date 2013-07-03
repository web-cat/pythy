class CourseOfferingScores

  # -------------------------------------------------------------
  def initialize(course_offering)
    @course_offering = course_offering
    @users = @course_offering.users_sorted_by_role
    @assignment_offerings = @course_offering.assignment_offerings

    @scores = {}

    @gathered = false
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
  def info_for_user_and_assignment_offering(user, assignment_offering)
    gather_scores unless @gathered
    user_scores = @scores[user.id]
    user_scores ? user_scores[assignment_offering.id] : nil
  end


  private

  # -------------------------------------------------------------
  def gather_scores
    user_ids = @users.map(&:id).join(',')
    assignment_offering_ids = @assignment_offerings.map(&:id).join(',')

    # In English: Find the most recent (highest number) assignment check for
    # each (User, AssignmentOffering) pair from the @users and
    # @assignment_offerings arrays. I'm not worried about SQL injection in
    # the variable interpolation below because the variables come directly
    # from database IDs, not user input.
    rows = AssignmentCheck.connection.select_all(
      "SELECT
         `assignment_checks`.`id`,
         `assignment_checks`.`overall_score`,
         `repositories`.`user_id`,
         `repositories`.`assignment_offering_id`,
         `repositories`.`id` as `repository_id`
       FROM `assignment_checks`
       INNER JOIN `repositories`
         ON `repositories`.`id` = `assignment_checks`.`assignment_repository_id`
       INNER JOIN (
         SELECT `assignment_checks`.`assignment_repository_id`,
         MAX(`number`) AS `max_number`
         FROM `assignment_checks`
         INNER JOIN `repositories`
         ON `repositories`.`id` = `assignment_checks`.`assignment_repository_id`
         AND `repositories`.`type` IN ('AssignmentRepository')
         WHERE `repositories`.`user_id` IN (#{user_ids})
         AND `repositories`.`assignment_offering_id` IN (#{assignment_offering_ids})
         GROUP BY `assignment_checks`.`assignment_repository_id`
       ) `max_checks`
       ON `assignment_checks`.`assignment_repository_id` =
          `max_checks`.`assignment_repository_id`
       AND `assignment_checks`.`number` = `max_checks`.`max_number`
      ")

    # Since the result above just comes back as a flat array of row hashes,
    # now we have to project them into a 2D "matrix" (hash of hashes) for
    # easy lookup later.
    rows.each do |row|
      score = row['overall_score']
      user_id = row['user_id']
      assignment_offering_id = row['assignment_offering_id']
      repository_id = row['repository_id']
      check_id = row['id']

      @scores[user_id] ||= {}
      @scores[user_id][assignment_offering_id] = {
        score: score,
        assignment_check_id: check_id,
        repository_id: repository_id
      }
    end

    @gathered = true
  end

end
