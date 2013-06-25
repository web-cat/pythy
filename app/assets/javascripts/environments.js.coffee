$ ->
  # -------------------------------------------------------------
  # Create CodeMirror widgets on the editing page.
  if $('#environment_preamble').length
    CodeMirror.fromTextArea $('#environment_preamble')[0],
      mode: { name: "python", version: 3, singleLineStringErrors: false },
      lineNumbers: true,
      gutters: ["CodeMirror-linenumbers"]
      indentUnit: 2,
      tabSize: 2,
      indentWithTabs: false,
      matchBrackets: true,
      extraKeys: { Tab: (cm) -> cm.replaceSelection('  ', 'end') }
