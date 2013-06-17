class AddResourceKeyToUsers < ActiveRecord::Migration

  def change
    add_column :users, :resource_key, :string
    add_index :users, :resource_key
  end

end
