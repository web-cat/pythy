$ ->
  options = {
    theme: 'markdown default',
    mode: { name: "markdown" },
    lineWrapping: true,
    indentUnit: 2,
    tabSize: 2,
    tabMode: "shift",
  }

  if $('#assignment_description').length
    CodeMirror.fromTextArea $('#assignment_description')[0], options

  if $('#assignment_brief_summary').length
    CodeMirror.fromTextArea $('#assignment_brief_summary')[0], options
