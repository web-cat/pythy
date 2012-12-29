$('#course_enrollments').html(
  '<%= escape_javascript render(@course_enrollment.course_offering.course_enrollments) %>')
