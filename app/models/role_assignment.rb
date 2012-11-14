class RoleAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :global_role
  attr_accessible :user, :global_role
end
