$('#course_enrollments').html(
  '<%= escape_javascript render(@course_offering.course_enrollments) %>')

$('#course_enrollment_modal').modal('hide')
