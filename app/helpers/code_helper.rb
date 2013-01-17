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


  # -------------------------------------------------------------
  def outcome_bar(outcome)
    if outcome.score && outcome.possible_score
      score = 100.0 * outcome.score / outcome.possible_score
    else
      score = 0.0
    end

    if score < 0.001
      bar_color = 'progress-danger'
    elsif score > 99.999
      bar_color = 'progress-success'
    else
      bar_color = 'progress-warning'
    end

    if outcome.possible_score == 1.0
      if score < 0.001
        bar_text = icon_tag('remove')
      else
        bar_text = icon_tag('ok')
      end

      progress = 100
    else
      bar_text = "#{score.round}%"
      progress = score
    end

    content_tag :div, class: "progress #{bar_color}" do
      content_tag :div, class: 'bar', style: "width: #{progress}%" do
        bar_text
      end
    end
  end


  # -------------------------------------------------------------
  def code_check_results_link(check)
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}?message=check_results&check=#{check.id}"
  end


  # -------------------------------------------------------------
  def score_tile_label(check)
    score = check.overall_score || 0

    if score < 70
      color = 'important'
    elsif score < 90
      color = 'warning'
    else
      color = 'success'
    end

    content_tag :div, class: "pull-right score-label label label-#{color}" do
      "#{score.round}%"
    end
  end

end
