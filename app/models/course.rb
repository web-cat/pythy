#
# A course represents a course (which may have multiple sections; see
# course_offering.rb) at an organization, such as "CS 1064".
#
class Course < ActiveRecord::Base
  
  # Relationships
  belongs_to  :organization
  belongs_to  :default_environment, class_name: 'Environment'
  has_many    :course_offerings
  has_many    :assignments

  attr_accessible :organization_id, :name, :number, :default_environment_id

  before_validation :set_url_part

  with_options presence: true do |course|
    course.validates :number, uniqueness: { case_sensitive: false }
    course.validates :name
    course.validates :default_environment
    course.validates :organization
    course.validates :url_part, uniqueness: { case_sensitive: false }
  end

  after_update :update_file_path

  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.from_path_component(component)
    where(url_part: component)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def offering_with_short_label(short_label, term)
    course_offerings.where(short_label: short_label, term_id: term.id).first
  end


  # -------------------------------------------------------------
  def offerings_for_user(user, term)
    if user.global_role.can_manage_all_courses?
      course_offerings.where(term_id: term.id)
    else
      course_offerings.joins(:course_enrollments).where(
        'course_offerings.term_id = ? and course_enrollments.user_id = ?',
        term.id, user.id)
    end
  end

  # -------------------------------------------------------------
  # Public: Gets the path to the directory where repositories and other
  # resources for this Course will be stored.
  #
  # Returns the path to the Course's storage directory.
  def storage_path
    File.join(organization.storage_path, url_part)
  end


  private

  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(number)
  end
  
  
  # -------------------------------------------------------------
  # Updates the file structure to reflect the changes made to
  # this course model.
  def update_file_path
    if self.number_changed? || self.organization_id_changed?
      old_organization = Organization.find(self.organization_id_was)
      old_url_part = url_part_safe(self.number_was)
      
      old_path = File.join(old_organization.storage_path, old_url_part)
      
      if File.directory?(old_path)
        new_path = self.storage_path
        
        # If the organization folder does not exist, create it.
        if !File.directory?(self.organization.storage_path)
          FileUtils.mkdir_p self.organization.storage_path
        end
        
        FileUtils.mv old_path, new_path
      end
    end
  end

end
