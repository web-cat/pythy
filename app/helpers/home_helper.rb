module HomeHelper

  # -------------------------------------------------------------
  def course_exists?
    @organization && @course && @term
  end


  # -------------------------------------------------------------
  def home_path(model=nil, options={})
    term = options[:term]
    path_parts = []

    if model.is_a?(CourseOffering)
      path_parts.unshift model.crn.to_s
      term = model.term
      model = model.course
    end

    if term
      path_parts.unshift term.url_part
    end

    if model.is_a?(Course)
      path_parts.unshift model.url_part
      model = model.organization
    end

    if model.is_a?(Organization)
      path_parts.unshift model.url_part
      model = nil
    end

    path_parts.unshift 'home'

    '/' + File.join(path_parts)
  end


  # -------------------------------------------------------------
  def code_path(model, path=nil)
    path_parts = []
    path_parts.unshift path if path

    if model.is_a?(AssignmentReferenceRepository)
        path_parts.unshift model.assignment.url_part
        path_parts.unshift 'assignments'
        path_parts.unshift model.assignment.course.url_part
        model = model.assignment.course.organization
    else
      if model.is_a?(ExampleRepository)
        # TODO use a friendlier name
        path_parts.unshift model.id.to_s
        path_parts.unshift 'example'
        model = model.course_offering
      elsif model.is_a?(AssignmentOffering)
        path_parts.unshift model.assignment.url_part
        path_parts.unshift 'assignments'
        model = model.course_offering
      end

      if model.is_a?(CourseOffering)
        path_parts.unshift model.crn.to_s
        path_parts.unshift model.term.url_part
        path_parts.unshift model.course.url_part
        model = model.course.organization
      end
    end

    if model.is_a?(Organization)
      path_parts.unshift model.url_part
      model = nil
    end

    path_parts.unshift 'code'

    '/' + File.join(path_parts)
  end


  # -------------------------------------------------------------
  def staff_code_url(model, path=nil)
    path_parts = []
    path_parts.unshift path if path

    if model.is_a?(AssignmentRepository)
      path_parts.unshift model.assignment_offering.assignment.url_part
      path_parts.unshift model.user.id.to_s
      model = model.assignment_offering.course_offering
    end

    if model.is_a?(CourseOffering)
      path_parts.unshift model.crn.to_s
      path_parts.unshift model.term.url_part
      path_parts.unshift model.course.url_part
      model = model.course.organization
    end

    if model.is_a?(Organization)
      path_parts.unshift model.url_part
      model = nil
    end

    path_parts.unshift 'code'

    URI::encode('/' + File.join(path_parts))
  end


  # -------------------------------------------------------------
  def assignment_date_tag(offering)
    span_class = 'live-date hang-tag small'

    if offering.past_due?
      span_class += ' danger'
    elsif offering.effectively_due_at
      if offering.effectively_due_at - Time.now < 3.days
        span_class += ' caution'
      else
        span_class += ' good'
      end
    else
      return
    end

    content_tag :div, class: span_class, data: {
      date: offering.effectively_due_at.to_i * 1000,
      format: 'Due {0}'
    } do
      ""
    end
  end


  # -------------------------------------------------------------
  def assignment_date_text(offering)
    due = offering.due_at
    closes = offering.closes_at

    if due.nil? && closes.nil?
      'Open forever'
    else
      if due.nil? && !closes.nil?
        due = closes
      end

      distance = distance_of_time_in_words_to_now(due)

      if due < Time.now
        distance = "Due #{distance} ago"

        if !closes.nil? && due != closes
          close_distance = distance_of_time_in_words_to_now(closes)

          if closes < Time.now
            close_distance = "closed #{close_distance} ago"
          else
            close_distance = "closes in #{close_distance}"
          end

          distance = "#{distance}; #{close_distance}"
        end
      else
        distance = "Due in #{distance}"
      end

      distance
    end
  end


  # -------------------------------------------------------------
  def score_tile(check)
    if check
      score = check.overall_score || 0

      if score < 70
        btn_color = 'danger'
      elsif score < 90
        btn_color = 'warning'
      else
        btn_color = 'good'
      end

      content_tag :div, class: "assignment-score score-#{btn_color}" do
        "#{score.round}%"
      end
    else
      content_tag :div, class: "assignment-score score-none" do
        '--%'
      end
    end
  end


  # -------------------------------------------------------------
  def can_manage_anything?
    can?(:manage, User) ||
    can?(:manage, Organization) ||
    can?(:manage, Term) ||
    can?(:manage, GlobalRole) ||
    can?(:manage, CourseRole) ||
    can?(:manage, SystemConfiguration)
  end


  # -------------------------------------------------------------
  def current_course_offering?(course_offering)
    course_offering.crn.to_s == params[:crn] &&
      course_offering.term.url_part == params[:term]
  end

end
