class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.references :assignment

      t.timestamps
    end
    add_index :projects, :assignment_id
  end
end
