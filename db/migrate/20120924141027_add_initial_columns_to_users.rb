class AddInitialColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :institution_id, :integer
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :global_role_id, :integer
  end
end
