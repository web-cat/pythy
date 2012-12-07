class Authentication < ActiveRecord::Base

  belongs_to :user

  attr_accessible :provider, :uid

  def apply_omniauth(user, omniauth)
    puts omniauth.to_yaml
    user.email = omniauth['info']['email']
    user.full_name = omniauth['info']['name']
    user.password ||= Devise.friendly_token.first(20)
  end

end
