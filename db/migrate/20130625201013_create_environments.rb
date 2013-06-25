class CreateEnvironments < ActiveRecord::Migration

  def change
    create_table :environments do |t|
      t.string :name
      t.text :preamble
      t.timestamps
    end
  end

end
