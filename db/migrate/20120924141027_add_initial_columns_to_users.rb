class AddInitialColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :institution_id, :integer
    add_column :users, :full_name, :string
  end
end
