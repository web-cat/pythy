# Append the modal to the page body.
$('body').append(
  '<%= j render partial: "code/choose_environment_modal" %>')
$('#choose_environment_modal select').selectpicker()

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#choose_environment_modal').on 'hidden', ->
  $('#choose_environment_modal').remove()

$('#choose_environment_modal').on 'shown', ->
  $('#choose_environment_modal #set-environment').click (e) ->
    env_id = $('#choose_environment_modal #environment').val()

    attributes = environment_id: env_id
    data = {}
    data['<%= model_name %>'] = attributes

    $.ajax('<%= update_url %>',
      type: 'PUT',
      dataType: 'json',
      data: data
    ).success (result) ->
      window.codeController.setPreamble(result.environment.preamble)

    $('#choose_environment_modal').modal('hide')

# Display the dialog.
$('#choose_environment_modal').modal('show')
