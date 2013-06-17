# Append the modal to the page body.
$('body').append '<%= j render partial: "media/modal" %>'

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#media_library_modal').on 'hidden', ->
  $('#media_library_modal').remove()

# Display the dialog.
$('#media_library_modal').modal('show')
