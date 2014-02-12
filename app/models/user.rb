#--------------------------------------------------------------------------
# Describes a user in the system.
class User < ActiveRecord::Base

  include ResourceKeyMethods

  include Gravtastic
  gravtastic secure: true, default: 'mm'

  delegate    :can?, :cannot?, to: :ability

  belongs_to  :global_role
  
  has_many    :authentications
  has_many    :activity_logs
  has_many    :course_enrollments
  has_many    :course_offerings, through: :course_enrollments
  has_many    :assignment_offerings, through: :course_offerings
  has_many    :media_items
  has_one     :scratchpad_repository

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable,
  # :timeoutable and :omniauthable

  # devise :rememberable, :trackable, :validatable
  devise :registerable, :database_authenticatable, :rememberable,
    :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation,
    :remember_me, :global_role_id, :course_offerings, :course_enrollments, :current_course_id, :current_term_id

  validates :first_name, presence: true
  validates :last_name, presence: true

  before_create :set_default_role
  
  after_update :update_file_paths

  paginates_per 100

  scope :search, lambda { |query|
    unless query.blank?
      arel = self.arel_table
      pattern = "%#{query}%"
      where(arel[:email].matches(pattern).or(
            arel[:first_name].matches(pattern)).or(
            arel[:last_name].matches(pattern)))
    end
  }

  scope :alphabetical, -> { order('last_name asc, first_name asc, email asc') }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.all_emails(prefix = '')
    self.uniq.where(self.arel_table[:email].matches(
      "#{prefix}%")).reorder('email asc').pluck(:email)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def storage_path
    File.join(
      SystemConfiguration.first.storage_path, 'users', email)
  end


  # -------------------------------------------------------------
  def ability
    @ability ||= Ability.new(self)
  end

  def courses
    # use this method to make sure list is accurate (and not an outdated cache).
    CourseOffering.uncached do
      @user_offerings = self.course_offerings
    end
    
    courses = {}
    @user_offerings.each do |offering|
      term_id = offering.term.id.to_s
      if courses[term_id]
        courses[term_id] |= [offering.course]
      else
        courses[term_id] = [offering.course]
      end
    end
    
    return courses
  end

  # -------------------------------------------------------------
  # Public: Gets a relation representing all of the CourseOfferings that
  # this user can manage.
  #
  # Returns a relation representing all of the CourseOfferings that this
  # user can manage
  #
  def managing_course_offerings
    self.course_offerings.select{ |o| o.role_for_user(self).can_manage_course? }
  end


  # -------------------------------------------------------------
  # Gets the user's "display name", which is their full name if it is in the
  # database, otherwise it is their e-mail address.
  def display_name
    first_name.blank? || last_name.blank? ? email : first_name + " " + last_name
  end


  # -------------------------------------------------------------
  # Gets the username (without the domain) of the e-mail address, if possible.
  def email_without_domain
    if email =~ /(^[^@]+)@/
      $1
    else
      email
    end
  end


  private

  # -------------------------------------------------------------
  # Sets the first user's role as administrator and subsequent users
  # as student (note: be sure to run rake db:seed to create these roles)
  def set_default_role
    if User.count == 0
      self.global_role = GlobalRole.administrator
    else
      self.global_role = GlobalRole.regular_user
    end
  end
  
  
  # -------------------------------------------------------------
  # Updates the file structure to reflect the changes made to
  # this user model.
  def update_file_paths
    if self.email_changed?
      old_storage_path = File.join(SystemConfiguration.first.storage_path, 'users', self.email_was)
      
      # If the directory exists, move/rename it.
      if File.directory?(old_storage_path)        
        FileUtils.mv old_storage_path, File.join(SystemConfiguration.first.storage_path, 'users', self.email)
      end
      
      self.assignment_offerings.each do |assignment_offering|
        old_assignment_path = File.join(
                                assignment_offering.course_offering.storage_path,
                                'assignments',
                                assignment_offering.assignment.url_part,
                                self.email_was)
                                
        # If the directory exists, move/rename it.
        if File.directory?(old_assignment_path)        
          FileUtils.mv old_assignment_path, File.join(
                                              assignment_offering.course_offering.storage_path,
                                              'assignments',
                                              assignment_offering.assignment.url_part,
                                              self.email)
        end
      end
      
    end
  end


  # -------------------------------------------------------------
  # Overrides the built-in password required method to allow for users
  # to be updated without errors
  # taken from: http://www.chicagoinformatics.com/index.php/2012/09/user-administration-for-devise/
  def password_required?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

end
