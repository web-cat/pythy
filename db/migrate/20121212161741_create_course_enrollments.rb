class CreateCourseEnrollments < ActiveRecord::Migration
  def change
    create_table :course_enrollments do |t|
      t.references :user
      t.references :course_offering
      t.references :course_role
    end
    add_index :course_enrollments, :user_id
    add_index :course_enrollments, :course_offering_id
    add_index :course_enrollments, :course_role_id

    # disallow duplicate enrollments 
    add_index :course_enrollments, [:user_id, :course_offering_id], :unique => true
  end
end
