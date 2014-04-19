class SystemConfiguration < ActiveRecord::Base
  attr_accessible :storage_path, :work_path

  with_options presence: true, path: true do |sys_config|
    sys_config.validates :storage_path
    sys_config.validates :work_path
  end

end
