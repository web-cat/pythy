# =============================================================================
# Found at http://gist.github.com/3149393, modified for Pythy use
class ChangeableValidator < ActiveModel::EachValidator
  # Enforce/prevent attribute change
  #
  # Example: Make attribute immutable once saved
  # validates :attribute, changeable: false, on: :update
  #
  # Example: Force attribute change on every save
  # validates :attribute, changeable: true
  
  def initialize(options)
    options[:changeable] = !(options[:with] === false)
    super
  end
  
  def validate_each(record, attribute, value)
    unless record.public_send(:"#{attribute}_changed?") == options[:changeable]
      record.errors.add(attribute,
        "#{options[:changeable] ? 'must' : 'cannot'} be modified")
    end
  end
end
