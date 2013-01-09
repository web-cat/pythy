$ ->
  CodeMirror.fromTextArea $('#assignment_description')[0],
    theme: 'markdown default',
    mode: { name: "markdown" },
    lineWrapping: true,
    indentUnit: 2,
    tabSize: 2,
    tabMode: "shift",
