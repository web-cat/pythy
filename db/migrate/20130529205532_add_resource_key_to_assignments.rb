class AddResourceKeyToAssignments < ActiveRecord::Migration

  def change
    add_column :assignments, :resource_key, :string
    add_index :assignments, :resource_key
  end

end
