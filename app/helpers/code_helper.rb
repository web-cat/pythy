module CodeHelper

  # -------------------------------------------------------------
  def user_list_item_class(repository, user)
    if user.can? :manage, repository
      'indicator manager'
    elsif repository.user_unsynched?(user)
      'indicator unsynched'
    else
      nil
    end
  end


  # -------------------------------------------------------------
  def user_list_item_title(repository, user)
    title = user.display_name

    if user.can? :manage, repository
      title += ' (manager)'
    elsif repository.user_unsynched?(user)
      title += ' (unsynched)'
    end

    title
  end


  # -------------------------------------------------------------
  def score_bar(score)
    score ||= 0
    
    success_bar = "#{score.round}%"
    danger_bar = ""

    if score < 20
      success_bar = ""
      danger_bar = "#{score.round}%"
    end

    content_tag :div, class: "progress" do
      content_tag(:div, success_bar, class: 'bar bar-success', style: "width: #{score}%") +
      content_tag(:div, danger_bar, class: 'bar bar-danger', style: "width: #{100 - score}%")
      
    end
  end


  # -------------------------------------------------------------
  def score_badge(score)
    score ||= 0

    if score < 70
      bar_color = 'label-important'
    elsif score < 90
      bar_color = 'label-warning'
    else
      bar_color = 'label-success'
    end

    content_tag :span, class: "label #{bar_color}" do
      "#{score.round}%"
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


  # -------------------------------------------------------------
  def skulpt_javascript_include_tags
    javascript_include_tag('internal/skulpt') +
    javascript_include_tag('internal/builtin')
  end


  # -------------------------------------------------------------
  def action_button_tag(options = {})
    link_to(options[:url] || 'javascript:void(0)',
      id: options[:id],
      class: "btn #{options[:class] || ''}",
      rel: 'tooltip',
      title: options[:tooltip],
      disabled: options[:disabled],
      data: { placement: 'left' }) do
        icon_tag(options[:icon]) + (block_given? && yield || '')
    end
  end

end
