class AddDefaultEnvironmentIdToCourses < ActiveRecord::Migration

  def change
    add_column :courses, :default_environment_id, :integer
  end

end
