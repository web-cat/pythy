$ ->
  options = {
    theme: 'markdown default',
    mode: { name: "markdown" },
    lineWrapping: true,
    indentUnit: 2,
    tabSize: 2,
    tabMode: "shift",
  }

  CodeMirror.fromTextArea $('#assignment_description')[0], options
  CodeMirror.fromTextArea $('#assignment_brief_summary')[0], options
