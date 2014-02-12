class AddCurrentCourseAndCurrentTermToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_course_id, :integer
    add_column :users, :current_term_id, :integer
  end
end
