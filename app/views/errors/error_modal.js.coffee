# Append the course enrollments dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "errors/modal", locals: { status: status }) %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#error_modal').on 'hidden', ->
  $('#error_modal').remove()

# Display the dialog.
$('#error_modal').modal('show')
