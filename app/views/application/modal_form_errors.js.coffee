$('#<%= controller_name %>_modal #flashbar-placeholder').html(
  '<%= escape_javascript(render partial: "form_errors", locals: { model: model }) %>')