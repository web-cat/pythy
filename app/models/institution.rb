class Institution < ActiveRecord::Base

  has_many    :departments
  has_many    :users

  attr_accessible :display_name, :domain, :abbreviation

  before_validation :set_url_part

  #~ Validation ...............................................................

  validates :abbreviation,
    format: {
      with: /[a-zA-Z0-9\-_.]+/,
      message: 'must contain only [a-zA-Z0-9-_.] only'
    },
    uniqueness: { case_sensitive: false }

  validates :display_name, presence: true
  
  validates :domain, presence: true, uniqueness: { case_sensitive: false }
  
  validates :url_part,
    presence: true,
    uniqueness: {
      case_sensitive: false
    }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.from_path_component(component)
    where(url_part: component)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def storage_path
    File.join(
      SystemConfiguration.first.storage_path,
      url_part)
  end


  private

  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(abbreviation)
  end

end
