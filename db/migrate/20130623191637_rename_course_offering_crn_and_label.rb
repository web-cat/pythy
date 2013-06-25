class RenameCourseOfferingCrnAndLabel < ActiveRecord::Migration

  def up
    rename_column :course_offerings, :crn, :short_label
    change_column :course_offerings, :short_label, :string

    rename_column :course_offerings, :label, :long_label
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
