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


  # -------------------------------------------------------------
  def score_bar(score)
    score ||= 0

    if score < 70
      bar_color = 'progress-danger'
    elsif score < 90
      bar_color = 'progress-warning'
    else
      bar_color = 'progress-success'
    end

    content_tag :div, class: "progress progress-striped #{bar_color}" do
      content_tag :div, class: 'bar', style: "width: #{score}%" do
        "#{score.round}%"
      end
    end
  end

end
