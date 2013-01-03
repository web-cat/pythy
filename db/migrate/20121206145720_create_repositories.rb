class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :type
      t.integer :user_id
      t.integer :term_id
      t.timestamps

      # when type == 'AssignmentRepository'
      t.integer :assignment_offering_id

      # when type == 'ExampleRepository'
      t.integer :course_offering_id
      t.text :description
      t.integer :source_repository_id

      # when type == 'PersonalRepository' or 'ExampleRepository'
      t.string :name

      # when type == 'ScratchpadRepository', no extra columns yet
    end
  end
end
