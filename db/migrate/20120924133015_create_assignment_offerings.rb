class CreateAssignmentOfferings < ActiveRecord::Migration
  def change
    create_table :assignment_offerings do |t|
      t.integer :assignment_id
      t.integer :course_offering_id
      t.boolean :published
      t.datetime :due_at

      t.timestamps
    end
  end
end
