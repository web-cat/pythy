module UsersHelper

  # -------------------------------------------------------------
  def full_name_or_none(user, options={})
    if !user.first_name.blank? && !user.last_name.blank?
      options[:query] ? query_highlight(user.first_name + ' ' + user.last_name) : user.first_name + ' ' + user.last_name
    elsif options[:muted]
      raw(content_tag :span, '(none given)', class: 'muted')
    else
      '(none given)'
    end
  end

end
