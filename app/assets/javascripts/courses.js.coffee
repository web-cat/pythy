$ ->
  # -------------------------------------------------------------
  # New/edit course: when a different department is selected in the select
  # field, change the add-on span to the left of the course number field
  # to the new department's abbreviation.
  #
  $('#course_department_id').change ->
    department = $(this).val()
    $.get '/departments/' + department + '.json', (data) ->
      $('#course_number_control_group span.add-on').text(data.abbreviation)
    , 'json'
