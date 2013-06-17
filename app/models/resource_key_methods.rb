require 'securerandom'

module ResourceKeyMethods
  extend ActiveSupport::Concern

  included do
    before_save :generate_resource_key
  end


  # -------------------------------------------------------
  def generate_resource_key
    unless self.resource_key
      loop do
        key = SecureRandom.urlsafe_base64(10)
        break unless self.class.where(resource_key: key).exists?
      end

      self.resource_key = key
    end
  end

end
