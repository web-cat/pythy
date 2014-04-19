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
  # Public: Gets a Redis key with the specified name, prefixed by the model's
  # class name and database ID as a namespace.
  #
  # key - the key suffix (e.g. "foo")
  #
  # Returns the namespaced key (e.g. "Model:4:foo")
  #
  def redis_key(key)
    "#{self.class.name}:#{self.id}:#{key}"
  end


  # -------------------------------------------------------------
  # Public: Gets the name of a server-side events channel for this
  # model. This allows us to write controllers that can easily publish
  # events about any kind of object in the system, and have Javascript
  # code client-side respond to those events immediately.
  #
  # suffix - the suffix to attach to the channel name; can be nil
  #
  # Returns the subscription channel name (e.g. "Model_4_foo", or
  # "Model_4" if the suffix is nil).
  #
  def event_channel(suffix)
    if suffix
      "#{self.class.name}_#{self.id}_#{suffix.to_s}"
    else
      "#{self.class.name}_#{self.id}"
    end
  end

end

ActiveRecord::Base.send(:include, PythyActiveRecordExtensions)

# =============================================================================
# A wrapper for the <=> operator that handles nil arguments correctly,
# ordering them before non-nil objects.
def nil_safe_compare(a, b)
  if a.nil? && b.nil?
    0
  elsif a.nil?
    -1
  elsif b.nil?
    1
  else
    a <=> b
  end
end
