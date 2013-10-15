class AddTermIdToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :term_id, :integer
  end
end
