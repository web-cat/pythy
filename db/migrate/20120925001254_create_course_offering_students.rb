class CreateCourseOfferingStudents < ActiveRecord::Migration
  def change
    create_table :course_offering_students, :id => false do |t|
      t.integer :course_offering_id
      t.integer :user_id
    end
  end
end
