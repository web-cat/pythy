class CreateInstitutions < ActiveRecord::Migration

  def change
    create_table :institutions do |t|
      t.string :domain
      t.string :display_name
      t.string :abbreviation
      t.string :url_part
      t.timestamps
    end

    add_index :institutions, :abbreviation, unique: true
    add_index :institutions, :domain,       unique: true
    add_index :institutions, :url_part,     unique: true
  end

end
