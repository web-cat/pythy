class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.integer :institution_id
      t.string :name
      t.string :abbreviation
      t.string :url_part
      t.timestamps
    end
  end
end
