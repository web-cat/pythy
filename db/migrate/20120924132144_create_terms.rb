class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.integer :year
      t.integer :season
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end
  end
end
