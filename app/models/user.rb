#--------------------------------------------------------------------------
# Describes a user in the system. Currently, users are authenticated using
# the Virginia Tech LDAP server. We will need to generalize this eventually
# so that the system can be adopted on a larger scale. (TODO look into ways
# of supporting multiple authenticators in Devise.)
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

  # devise :ldap_authenticatable, :rememberable, :trackable, :validatable
  devise :registerable, :database_authenticatable, :rememberable,
    :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :full_name, :email, :password, :password_confirmation,
    :remember_me, :global_role_id, :course_offerings, :course_enrollments

  validates :full_name, presence: true

  before_create :set_default_role

  paginates_per 15

  scope :search, lambda { |query|
    unless query.blank?
      arel = self.arel_table
      pattern = "%#{query}%"
      where(arel[:email].matches(pattern).or(
            arel[:full_name].matches(pattern)))
    end
  }

  scope :alphabetical, order('full_name asc, email asc')


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


  # -------------------------------------------------------------
  # Public: Gets a relation representing all of the CourseOfferings that
  # this user can manage.
  #
  # Returns a relation representing all of the CourseOfferings that this
  # user can manage
  #
  def managing_course_offerings
    # It seems like I should have been able to do this through the
    # course_offerings association directly somehow, but writing
    # course_offerings.joins(...) resulted in a double-join. This seems
    # to work correctly instead.
    CourseOffering.joins(:course_enrollments => :course_role).where(
      course_enrollments: { user_id: id },
      course_roles: { can_manage_course: true })
  end


  # -------------------------------------------------------------
  # Gets the user's "display name", which is their full name if it is in the
  # database, otherwise it is their e-mail address.
  def display_name
    full_name.blank? ? email : full_name
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
  # Overrides the built-in password required method to allow for users
  # to be updated without errors
  # taken from: http://www.chicagoinformatics.com/index.php/2012/09/user-administration-for-devise/
  def password_required?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

end
