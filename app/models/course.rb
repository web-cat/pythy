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

  validates :number, presence: true
  validates :name, presence: true
  validates :default_environment, presence: true
  validates :url_part,
    presence: true,
    uniqueness: { case_sensitive: false }


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

end
