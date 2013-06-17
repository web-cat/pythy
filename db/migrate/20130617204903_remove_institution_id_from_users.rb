class RemoveInstitutionIdFromUsers < ActiveRecord::Migration

  def up
    remove_column :users, :institution_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
