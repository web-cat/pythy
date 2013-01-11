class CreateCheckOutcomes < ActiveRecord::Migration

  def change
    create_table :check_outcomes do |t|
      t.integer :assignment_check_id
      t.string :name
      t.string :category
      t.integer :position
      t.decimal :score, precision: 16, scale: 8
      t.decimal :possible_score, precision: 16, scale: 8
      t.timestamps
    end
  end

end
