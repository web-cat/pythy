module UsersHelper

  # -------------------------------------------------------------
  def full_name_or_none(user, options={})
    if !user.full_name.blank?
      user.full_name
    elsif options[:muted]
      raw(content_tag :span, '(none given)', class: 'muted')
    else
      '(none given)'
    end
  end

end
