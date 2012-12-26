#--------------------------------------------------------------------------
# Describes a user in the system. Currently, users are authenticated using
# the Virginia Tech LDAP server. We will need to generalize this eventually
# so that the system can be adopted on a larger scale. (TODO look into ways
# of supporting multiple authenticators in Devise.)
class User < ActiveRecord::Base

  belongs_to  :institution

  belongs_to  :global_role
  
  has_many    :authentications
  has_many    :activity_logs

  has_many    :course_offerings, :through => :course_enrollments
  has_many    :course_enrollments

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable,
  # :timeoutable and :omniauthable

  # devise :ldap_authenticatable, :rememberable, :trackable, :validatable
  devise :registerable, :database_authenticatable, :rememberable,
    :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :full_name, :email, :password, :password_confirmation,
    :remember_me, :global_role_id, :institution_id, :course_offerings,
    :course_enrollments

  before_create :set_default_role
#  before_save :get_institution


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.all_emails(prefix = '')
    self.uniq.where(self.arel_table[:email].matches(
      "#{prefix}%")).reorder('email asc').pluck(:email)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # Gets the user's "display name", which is their full name if it is in the
  # database, otherwise it is their e-mail address.
  def display_name
    full_name || email
  end


  private

  # -------------------------------------------------------------
  # Sets the first user's role as administrator and subsequent users
  # as student (note: be sure to run rake db:seed to create these roles)
  def set_default_role
    if User.count == 0
      self.global_role_id = GlobalRole::ADMINISTRATOR_ID
    else
      self.global_role_id = GlobalRole::STUDENT_ID
    end
  end

  # -------------------------------------------------------------
  # Populates the instition relationship by looking up an institution with
  # the e-mail domain of the user's e-mail address.
  def get_institution
    if email =~ /@(.*)$/
      domain = $1
      self.institution = Institution.where(domain: domain).first
    end
  end

  # -------------------------------------------------------------
  # Overrides the built-in password required method to allow for users
  # to be updated without errors
  # taked from: http://www.chicagoinformatics.com/index.php/2012/09/user-administration-for-devise/
  def password_required?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

end
