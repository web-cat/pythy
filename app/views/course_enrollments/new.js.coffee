# Append the course enrollments dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "course_enrollments/modal") %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#course_enrollment_modal').on 'hidden', ->
  $('#course_enrollment_modal').remove()

# Display the dialog.
$('#course_enrollment_modal').modal('show')
