module HomeHelper

  # -------------------------------------------------------------
  def course_exists?
    @institution && @term && @course
  end


  # -------------------------------------------------------------
  def course_offering_home_path(offering)
    course = offering.course
    term = offering.term
    institution = course.department.institution

    "/home/#{institution.url_part}/#{term.url_part}/#{course.url_part}/#{offering.crn}"
  end


  # -------------------------------------------------------------
  def code_path(model)
    path_parts = []

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
      path_parts.unshift model.course.url_part
      path_parts.unshift model.term.url_part
      model = model.course.department.institution
    end

    if model.is_a?(Institution)
      path_parts.unshift model.url_part
      model = nil
    end

    path_parts.unshift 'code'

    '/' + File.join(path_parts)
  end


  # -------------------------------------------------------------
  def assignment_date_wrapper(offering)
    span_class = nil

    if offering.past_due?
      span_class = 'label label-important'
    elsif offering.effectively_due_at
      if offering.effectively_due_at - Time.now < 3.days
        span_class = 'label label-warning'
      end
    end

    content_tag :span, class: span_class do
      yield
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

end
