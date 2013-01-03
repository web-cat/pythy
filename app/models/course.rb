#
# A course represents a course (which may have multiple sections; see
# course_offering.rb) in a department, such as "CS 1064".
#
class Course < ActiveRecord::Base
  
  # Relationships
  belongs_to  :department
  has_many    :course_offerings
  has_many    :assignments
  has_many    :example_repositories

  attr_accessible :department_id, :name, :number

  validates :number, presence: true
  validates :name, presence: true


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.from_path_component(path, institution)
    match = /(?<department>[a-z0-9]+)-(?<course_number>[a-z0-9]+)/.match(path)
    if match
      joins(:department).where(<<-SQL ,
        departments.url_part = ? and
        courses.number = ? and
        departments.institution_id = ?
        SQL
        match[:department], match[:course_number], institution.id)
    else
      where('1 = 0')
    end
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # Gets a string representing the short name of the course using its
  # department name and course number. For example, "CS 1064".
  #
  def department_name_and_number
  	"#{department.abbreviation} #{number}"
  end


  # -------------------------------------------------------------
  def offering_with_crn(crn, term)
    course_offerings.where(crn: crn, term_id: term.id).first
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
  def url_part
    "#{department.url_part}-#{number}"
  end

end
