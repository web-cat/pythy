class CreateAssignmentChecks < ActiveRecord::Migration

  def change
    create_table :assignment_checks do |t|
      t.integer :assignment_repository_id
      t.integer :number
      t.integer :status
      t.decimal :overall_score, precision: 16, scale: 8
      t.text :extra
      t.timestamps
    end
  end

end
