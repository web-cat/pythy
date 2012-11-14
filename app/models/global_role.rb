class GlobalRole < ActiveRecord::Base
  attr_accessible :can_edit_system_configuration, :can_manage_all_courses, :can_manage_own_courses, :description, :name
end
