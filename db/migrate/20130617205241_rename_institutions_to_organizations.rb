class RenameInstitutionsToOrganizations < ActiveRecord::Migration

  def change
    rename_table :institutions, :organizations
    rename_column :courses, :institution_id, :organization_id
  end

end
