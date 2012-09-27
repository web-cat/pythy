class AddInstitutionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :institution_id, :integer
  end
end
