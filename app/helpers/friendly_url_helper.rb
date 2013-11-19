module FriendlyUrlHelper

  # -------------------------------------------------------------
  def home_path(model=nil, options={})
    term = options[:term]
    path_parts = []

    if model.is_a?(CourseOffering)
      path_parts.unshift model.short_label
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
        path_parts.unshift 'assignment_reference'
        path_parts.unshift model.assignment.term.url_part        
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
        path_parts.unshift "offering_" + model.short_label
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
      elsif model.is_a?(AssignmentRepository)
        path_parts.unshift model.assignment_offering.id.to_s
        path_parts.unshift model.user.id.to_s
        model = model.assignment_offering.course_offering
      end

      if model.is_a?(CourseOffering)
        path_parts.unshift "offering_" +  model.short_label
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

    URI::encode('/' + File.join(path_parts))
  end

end
