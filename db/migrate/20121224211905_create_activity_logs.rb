class CreateActivityLogs < ActiveRecord::Migration

  def change
    create_table :activity_logs do |t|
      t.integer :user_id
      t.string :action
      t.text :info
      t.timestamps
    end
  end

end
