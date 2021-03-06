# Append the course enrollments dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "course_enrollments/modal") %>')

window.pythy.typeaheadUser()

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#course_enrollment_modal').on 'hidden', ->
  $('#course_enrollment_modal').remove()

$('#course_enrollment_modal').on 'shown', ->
  $('#course_enrollment_user_id').focus()

$('#course_enrollment_modal #enroll-users-button').button('loading')

# Display the dialog.
$('#course_enrollment_modal').modal('show')
