class CreateCourseOfferings < ActiveRecord::Migration
  def change
    create_table :course_offerings do |t|
      t.integer :course_id
      t.integer :term_id
      t.integer :crn
      t.string :label
      t.string :url

      t.timestamps
    end
  end
end
