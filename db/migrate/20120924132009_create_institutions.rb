class CreateInstitutions < ActiveRecord::Migration

  def change
    create_table :institutions do |t|
      t.string :abbreviation
      t.string :display_name
      t.string :domain

      t.timestamps
    end

    add_index :institutions, :abbreviation, unique: true
    add_index :institutions, :domain,       unique: true
  end

end
