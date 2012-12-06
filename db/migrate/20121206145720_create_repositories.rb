class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :type
      t.integer :user_id
      t.timestamps

      # when type == 'AssignmentRepository'
      t.integer :assignment_offering_id

      # when type == 'ExampleRepository'
      t.integer :course_id

      # when type == 'PersonalRepository'
      t.string :name

      # when type == 'ScratchpadRepository', no extra columns yet
    end
  end
end
