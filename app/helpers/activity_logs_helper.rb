module ActivityLogsHelper

  # -------------------------------------------------------------
  def filter_form
    form_tag({ controller: 'activity_logs', action: 'filter' },
      remote: true, class: 'form-search well well-small') do
      yield
    end
  end

end
