# Append the modal to the page body.
$('body').append('<%= j(render partial: "modal") %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#assignment_offerings_modal').on 'hidden', ->
  $('#assignment_offerings_modal').remove()

# Display the dialog.
$('#assignment_offerings_modal').modal('show')
