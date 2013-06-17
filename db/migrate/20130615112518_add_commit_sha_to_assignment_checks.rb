class AddCommitShaToAssignmentChecks < ActiveRecord::Migration

  def change
    add_column :assignment_checks, :commit_sha, :string
  end

end
