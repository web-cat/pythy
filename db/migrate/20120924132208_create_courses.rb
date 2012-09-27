class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :number
      t.integer :department_id

      t.timestamps
    end
  end
end
