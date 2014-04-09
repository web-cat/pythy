class SystemConfiguration < ActiveRecord::Base
  attr_accessible :storage_path, :work_path

  validates :storage_path, presence: true
  validates :work_path, presence: true
  validates_with PathValidator

end
