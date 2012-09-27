class CreateCourseOfferingStaff < ActiveRecord::Migration
  def change
    create_table :course_offering_staff, :id => false do |t|
      t.integer :course_offering_id
      t.integer :user_id
      t.boolean :manager
      t.integer :title
    end
  end
end
