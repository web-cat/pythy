class MergeFirstLastNameIntoFullName < ActiveRecord::Migration

  def up
    add_column :users, :full_name, :string

    # Before removing the old columns, concatenate the users' first and last
    # names into the single full_name column.
    execute 'update users set full_name = concat_ws(\' \', first_name, last_name)'

    remove_column :users, :first_name
    remove_column :users, :last_name
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
