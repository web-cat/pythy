$('#check').button('reset')

<% if assignment_check.status == AssignmentCheck::COMPLETED %>
$('#check-results').html(
  '<%= j render partial: "code/check_results",
    locals: { repository: assignment_check.assignment_repository } %>')

# Append the modal to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "code/check_outcomes_modal",
    locals: { assignment_check: assignment_check }) %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#check_outcomes_modal').on 'hidden', ->
  $('#check_outcomes_modal').remove()

# Display the dialog.
$('#check_outcomes_modal').modal('show')
<% elsif assignment_check.status == AssignmentCheck::FAILED %>
pythy.alert 'An internal error occurred when executing your code.'
<% elsif assignment_check.status == AssignmentCheck::TIMEOUT %>
pythy.alert 'Your code did not complete in the allowed amount of time.'
<% end %>
