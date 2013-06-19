class Authentication < ActiveRecord::Base

  belongs_to :user

  attr_accessible :provider, :uid

  def apply_omniauth(user, omniauth)
    if user.email.blank?
      user.email = omniauth['info']['email']
    end

    user.full_name ||= [omniauth['info']['first_name'],
      omniauth['info']['last_name']].join(' ')
    
    # Generate a dummy password for the user.
    user.password ||= Devise.friendly_token.first(20)
  end

end
