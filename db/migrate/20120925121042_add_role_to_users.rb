class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :global_role_id, :integer
  end
end
