class CreateMediaItems < ActiveRecord::Migration

  def change
    create_table :media_items do |t|
      t.integer :user_id
      t.integer :assignment_id
      t.string :file
      t.string :content_type
      t.integer :file_size
      t.text :info

      t.timestamps
    end
  end

end
