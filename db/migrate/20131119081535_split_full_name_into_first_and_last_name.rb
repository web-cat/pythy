class SplitFullNameIntoFirstAndLastName < ActiveRecord::Migration
  
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string    

    # Note: substring_index is a function specific to mysql and will not work
    # in other database systems like postgresql.
    execute 'update users set last_name = substring_index(full_name, \' \', -1)'
    execute 'update users set first_name = left(full_name, length(full_name) - locate(\' \', reverse(full_name)))'

    remove_column :users, :full_name
  end

  def down
    add_column :users, :full_name, :string

    # Before removing the old columns, concatenate the users' first and last
    # names into the single full_name column.
    execute 'update users set full_name = concat_ws(\' \', first_name, last_name)'

    remove_column :users, :first_name
    remove_column :users, :last_name
  end
  
end
