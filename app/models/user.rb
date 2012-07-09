#--------------------------------------------------------------------------
# Describes a user in the system. Currently, users are authenticated using
# the Virginia Tech LDAP server. We will need to generalize this eventually
# so that the system can be adopted on a larger scale. (TODO look into ways
# of supporting multiple authenticators in Devise.)
class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation,
    :remember_me

  before_save :get_ldap_email

  private

  # -------------------------------------------------------------
  # Populates the e-mail field from the LDAP directory entry once the user
  # has authenticated and his or her username is known.
  def get_ldap_email
    self.email = Devise::LdapAdapter.get_ldap_param(self.username, 'mail')
  end

end
