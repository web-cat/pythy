Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '204740312977274', 'c5315ec75271f0030534cdd27cfaa4a4'
  provider :ldap, :host => 'authn.directory.vt.edu',
    :port => 636,
    :method => :ssl,
    :base => 'ou=People,dc=vt,dc=edu',
    :uid => 'uupid'
end
