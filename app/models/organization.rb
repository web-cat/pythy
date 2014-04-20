class Organization < ActiveRecord::Base

  has_many :courses

  attr_accessible :display_name, :domain, :abbreviation

  before_validation :set_url_part
  
  after_update :update_file_path

  #~ Validation ...............................................................

  validates :abbreviation,
    format: {
      with: /\A[a-zA-Z0-9\-_.]+\Z/,
      message: 'must consist only of letters, digits, hyphens (-), ' \
        'underscores (_), and periods (.).'
    },
    uniqueness: { case_sensitive: false }

  validates :display_name, presence: true
  
  validates :url_part, presence: true, uniqueness: { case_sensitive: false }


  #~ Class methods ............................................................

  def self.from_path_component(component)
    where(url_part: component)
  end


  #~ Instance methods .........................................................

  def storage_path
    File.join(SystemConfiguration.first.storage_path, url_part)
  end


  def matches_user?(user)
    domain.blank? || user.email =~ /@#{Regexp.escape(domain)}$/
  end


  private

    def set_url_part
      self.url_part = url_part_safe(abbreviation)
    end
    
    # Updates the file structure to reflect the changes made to
    # this organization model.
    def update_file_path
      if self.url_part_changed?
        old_path = File.join(SystemConfiguration.first.storage_path, self.url_part_was)
        
        if File.directory?(old_path)
          new_path = self.storage_path
          
          FileUtils.mv old_path, new_path
        end
      end
    end

end
