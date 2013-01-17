class CreateSystemConfigurations < ActiveRecord::Migration

  def change
    create_table :system_configurations do |t|
      t.string :storage_path
      t.string :work_path
      t.timestamps
    end
  end

end
