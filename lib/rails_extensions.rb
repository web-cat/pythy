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
