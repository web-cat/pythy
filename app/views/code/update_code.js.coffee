<% if local_assigns[:environment] %>
window.codeController.setPreamble '<%= j raw environment.preamble || "" %>'
<% end %>
<% if local_assigns[:commit] %>
new_history_row = '<%= j render partial: "commit", locals: { commit: commit } %>'
amend = <%= amend %>
<% else %>
new_history_row = null
amend = false
<% end %>
window.codeController.updateCode '<%= j raw code %>', <%= force %>, new_history_row, amend
