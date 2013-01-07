# =============================================================================
class ActionView::Helpers::FormBuilder

  # -------------------------------------------------------------
  def date_field(attribute, *args, &block)
    options = args.extract_options!
    options[:value] = object[attribute] &&
      I18n.l(object[attribute].to_date).gsub(/\s+/, ' ')
    if options[:class]
      options[:class] = options[:class] + ' datepicker'
    else
      options[:class] = 'datepicker'
    end
    text_field(attribute, *(args << options), &block)
  end


  # -------------------------------------------------------------
  def datetime_field(attribute, *args, &block)
    options = args.extract_options!
    options[:value] = object[attribute] &&
      I18n.l(object[attribute]).gsub(/\s+/, ' ')
    if options[:class]
      options[:class] = options[:class] + ' datetimepicker'
    else
      options[:class] = 'datetimepicker'
    end
    text_field(attribute, *(args << options), &block)
  end

end


# =============================================================================
module PythyActiveRecordExtensions

  extend ActiveSupport::Concern

  # -------------------------------------------------------------
  def url_part_safe(value)
    value.downcase.gsub(/[^[:alnum:]]+/, '-').gsub(/-+$/, '')
  end


  # -------------------------------------------------------------
  # Gets a Redis key with the specified name, prefixed by the model's class
  # name and database ID as a namespace.
  #
  # key - the key suffix (e.g. "foo")
  #
  # Returns the namespaced key (e.g. "Model:4:foo")
  #
  def redis_key(key)
    "#{self.class.name}:#{self.id}:#{key}"
  end

end

ActiveRecord::Base.send(:include, PythyActiveRecordExtensions)


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
