$('#check-results').html(
  '<%= j render partial: "code/check_results", locals: { repository: repository } %>')
window.codeController.toggleSidebar true
