class DropDepartmentsTable < ActiveRecord::Migration

  def up
    drop_table :departments
    remove_column :courses, :department_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
