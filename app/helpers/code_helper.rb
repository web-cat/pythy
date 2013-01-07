module CodeHelper

  # -------------------------------------------------------------
  def user_list_item_tag(repository, user)
    css_class = nil

    if user.can? :manage, repository
      css_class = 'text-success'
    elsif repository.user_unsynched?(user)
      css_class = 'text-warning'
    end

    content_tag :span, class: css_class do
      yield
    end
  end

end
