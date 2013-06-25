class AddEnvironmentIdToRepositories < ActiveRecord::Migration

  def change
    add_column :repositories, :environment_id, :integer
  end

end
