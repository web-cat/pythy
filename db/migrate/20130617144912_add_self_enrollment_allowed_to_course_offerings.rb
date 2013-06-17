class AddSelfEnrollmentAllowedToCourseOfferings < ActiveRecord::Migration

  def change
    add_column :course_offerings, :self_enrollment_allowed, :boolean
  end

end
