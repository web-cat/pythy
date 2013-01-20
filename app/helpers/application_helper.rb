module ApplicationHelper

  # -------------------------------------------------------------
  # Gets a value indicating whether the application needs to present the
  # initial setup screen. This is currently true if the User table is empty,
  # meaning that nobody has accessed the application and created the initial
  # admin user.
  #
  def needs_initial_setup?
    User.count == 0
  end
  

  # -------------------------------------------------------------
  # Returns the correct twitter bootstrap class mapping for different
  # types of flash messages
  # 
  def flash_class(level)
    case level
    when :notice then 'alert-info'
    when :error then 'alert-error'
    when :alert then ''
    end
  end


  # -------------------------------------------------------------
  # Creates an <i> tag with the specified icon class.
  #
  # name: the icon class, without the 'icon-' prefix
  #
  def icon_tag(name)
    content_tag :i, nil, class: "icon-#{name}"
  end


  # -------------------------------------------------------------
  # Creates a Bootstrap close button, for alerts and such.
  #
  # Options:
  #   dismiss: the surrounding element to dismiss, such as 'alert'
  #
  def close_button_tag(options = {})
    content_tag :button, raw('&times;'), type: 'button', class: 'close',
      data: { dismiss: options[:dismiss] }
  end


  # Devise helpers

  # -------------------------------------------------------------
  def resource_name
    :user
  end

  # -------------------------------------------------------------
  def resource
    @resource ||= User.new
  end

  # -------------------------------------------------------------
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # -------------------------------------------------------------
  def devise_error_messages!
    return "" if resource.nil? || resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource_name)

    html = <<-HTML
<div id="error_explanation">
<h2>#{sentence}</h2>
<ul>#{messages}</ul>
</div>
HTML

    html.html_safe
  end

  # -------------------------------------------------------------
  def dropdown_tag
    content_tag :a, :href => '#', :class => 'dropdown-toggle',
      :'data-toggle' => 'dropdown' do
      yield
    end
  end


  # -------------------------------------------------------------
  def dropdown_button_tag(*args, &block)
    if block_given?
      options = args.first || {}
      dropdown_button_tag(capture(&block), options)
    else
      content = args.first
      options = args.second || {}

      if options[:class]
        options[:class] += ' dropdown-toggle'
      else
        options[:class] = 'dropdown_toggle'
      end

      if options[:data]
        options[:data][:toggle] = 'dropdown'
      else
        options[:data] = { toggle: 'dropdown' }
      end

      options[:href] = '#'

      content_tag :a, options do
        raw(content + ' <span class="caret"></span>')
      end
    end
  end


  # -------------------------------------------------------------
  def nav_item_tag(destination)
    content_tag :li, :class => ('active' if params[:controller] == destination.to_s) do
      link_to :controller => destination do
        yield
      end
    end
  end


  # -------------------------------------------------------------
  def tab_tag(*args, &block)
    if block_given?
      pane_id = args.first
      options = args.second || {}
      tab_tag(pane_id, capture(&block), options)
    else
      pane_id = args[0]
      content = args[1]
      options = args[2] || {}
      active = options.delete(:active)

      content_tag :li, :class => ('active' if active) do
        link_to content, "\##{pane_id}", data: { toggle: 'tab' }
      end
    end
  end


  # -------------------------------------------------------------
  def menu_link_to_if(condition, text, url, options = {})
    if condition
      content_tag :li do
        link_to text, url, options
      end
    end
  end


  # -------------------------------------------------------------
  def form_errors(model)
    render partial: 'form_errors', locals: { model: model }
  end


  # -------------------------------------------------------------
  def shallow_args(parent, child)
    child.try(:new_record?) ? [parent, child] : child
  end


  # -------------------------------------------------------------
  # Outputs a Twitter Bootstrap form with .form-horizontal, including an
  # error alert at the top (if there are any model errors), and handling
  # shallow nested arguments gracefully (in the case of new vs. edit).
  def pythy_form_for(*args, &block)
    options = {}

    if args.length >= 2 && !args[1].is_a?(Hash)
      parent = args[0]
      child = args[1]
      form_args = child.try(:new_record?) ? [parent, child] : child

      options = args[2] if args.length > 2 && args[2].is_a?(Hash)
    else
      parent = nil
      child = args[0]
      form_args = child

      options = args[1] if args.length > 1 && args[1].is_a?(Hash)
    end

    if options[:html]
      if options[:html][:class]
        options[:html][:class] += ' form-horizontal'
      else
        options[:html][:class] = 'form-horizontal'
      end
    else
      options[:html] = { class: 'form-horizontal' }
    end

    capture do
      twitter_bootstrap_form_for(form_args, options) do |f|
        concat form_errors child
        yield f
      end
    end
  end


  # -------------------------------------------------------------
  # Creates a text field with Twitter Bootstrap typeahead functionality.
  #
  # Options:
  #   url: the URL that will return a JSON array of entries for the field;
  #        it will be sent a parameter named "query" with the contents of
  #        the field
  #   submit: true to submit the parent form when an item is selected from
  #           the typeahead list
  #
  def typeahead_field_tag(name, value = nil, options = {})
    data = options['data'] || {}
    data.merge! provide: 'typeahead'
    data.merge! url: options.delete(:url)
    data.merge! submit: options.delete(:submit) && 'yes'
    options['data'] = data

    if options['class']
      options['class'] += ' typeahead'
    else
      options['class'] = 'typeahead'
    end

    options['autocomplete'] = 'off'

    text_field_tag name, value, options
  end


  # -------------------------------------------------------------
  def controller_stylesheet_link_tag
    c = params[:controller]
    stylesheet_link_tag c if Rails.application.assets.find_asset("#{c}.css")
  end


  # -------------------------------------------------------------
  def controller_javascript_include_tag
    c = params[:controller]
    javascript_include_tag c if Rails.application.assets.find_asset("#{c}.js")
  end


  # -------------------------------------------------------------
  def link_to_destroy(resource, options={})
    name = resource.class.name.humanize

    options.merge! method: :delete, data: {
      confirm: "Are you sure you want to delete this #{name}?",
      :'yes-class' => 'danger',
    }

    params = options[:params] || {}

    text = icon_tag('remove')
    text += ' Delete...' if options.delete(:text)

    link_to text,
      polymorphic_path(resource, params), options
  end


  # -------------------------------------------------------------
  def checkmark_if(value)
    value && content_tag(
      :span, raw('&#10003;'), class: 'label label-success') || ''
  end


  # -------------------------------------------------------------
  def index_search_form
    render(partial: 'index_search')
  end


  # -------------------------------------------------------------
  def query_highlight(text)
    if @query
      highlight(text, @query,
        highlighter: '<span class="query-highlight">\1</span>')
    else
      text
    end
  end


  # -------------------------------------------------------------
  def title(page_title)
    content_for(:title) { page_title }
  end


  # -------------------------------------------------------------
  def datetime_or_none(datetime, empty=nil)
    empty ||= '(not set)'
    if datetime
      l datetime
    else
      raw "<span class=\"muted\">#{empty}</span>"
    end
  end


  # -------------------------------------------------------------
  def juggernaut_javascript_include_tag
    #src = "http://#{request.host}:8080/application.js"
    #content_tag :script, nil, src: src, type: 'text/javascript', charset: 'utf-8'

    javascript_include_tag 'juggernaut'
  end

end
