<% if @committed %>
new_history_row = '<%= j render partial: "commit", locals: { commit: @commit_hash } %>'
window.codeController.updateHistory(new_history_row, <%= @committed[:amend] %>)
$('#save-state-icon').html('<i class="fa fa-check"></i>')
$('#save-state-message').html('saved')
<% end %>
<% if @repository.is_a?(AssignmentRepository) && !@repository.assignment_offering.closed? %>
$('#check').removeAttr('disabled')
<% end %>
