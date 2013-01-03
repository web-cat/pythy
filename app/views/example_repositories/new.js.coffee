# Append the modal to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "modal") %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#example_repository_modal').on 'hidden', ->
  $('#example_repository_modal').remove()

# Display the dialog.
$('#example_repository_modal').modal('show')
