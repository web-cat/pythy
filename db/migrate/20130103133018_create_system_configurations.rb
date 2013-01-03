class CreateSystemConfigurations < ActiveRecord::Migration
  def change
    create_table :system_configurations do |t|
      t.string :storage_path

      t.timestamps
    end
  end
end
