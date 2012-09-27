class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :domain
      t.string :display_name

      t.timestamps
    end
  end
end
