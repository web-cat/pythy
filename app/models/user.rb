#--------------------------------------------------------------------------
# Describes a user in the system. Currently, users are authenticated using
# the Virginia Tech LDAP server. We will need to generalize this eventually
# so that the system can be adopted on a larger scale. (TODO look into ways
# of supporting multiple authenticators in Devise.)
class User < ActiveRecord::Base

  # Roles:
  #   admin: Admins can do anything and manage all models.
  #   creator: Creators can create new courses by themselves, but do not
  #     have any other special privileges. (A non-creator can still be
  #     a manager for a course; he just can't create his own.)
  #   user: A default catch-all for a user with no special systemwide
  #     privileges (students, graders, and non-creating instructors).
  ROLES = %w( admin creator user )

  belongs_to  :institution

  has_many    :course_offering_students
  has_many    :enrolled_course_offerings,
              :through => :course_offering_students,
              :source => :course_offering

  has_many    :course_offering_staff
  has_many    :staffing_course_offerings,
              :through => :course_offering_staff,
              :source => :course_offering


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable,
  # :timeoutable and :omniauthable
  # devise :ldap_authenticatable, :rememberable, :trackable, :validatable
  devise :registerable, :database_authenticatable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation,
    :remember_me

  before_create :set_default_role
  before_save :get_ldap_email, :get_institution


  # -------------------------------------------------------------
  # Returns true if the user is an admin, otherwise false.
  def admin?
    role == 'admin'
  end


  private

  # -------------------------------------------------------------
  # Sets the default role for the user if it is not already set.
  def set_default_role
    if User.count == 0
      self.role = 'admin'
    else
      self.role ||= 'user'
    end
  end

  # -------------------------------------------------------------
  # Populates the e-mail field from the LDAP directory entry once the user
  # has authenticated and his or her username is known.
  def get_ldap_email
    # self.email = Devise::LdapAdapter.get_ldap_param(self.username, 'mail')
  end

  # -------------------------------------------------------------
  # Populates the instition relationship by looking up an institution with
  # the e-mail domain of the user's e-mail address.
  def get_institution
    if email =~ /@.*$/
      domain = $1
      self.institution = Institution.where(:domain => domain).first
    end
  end

end
