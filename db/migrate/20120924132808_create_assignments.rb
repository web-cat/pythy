class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :creator_id
      t.integer :course_id
      t.string :short_name
      t.string :long_name
      t.string :url_part
      t.text :description

      t.timestamps
    end
  end
end
