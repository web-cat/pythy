# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Document ready handler:
$ ->
  # Convert the text area to a CodeMirror widget.
  codeArea = CodeMirror.fromTextArea $('#codearea')[0],
    mode: { name: "python", version: 3, singleLineStringErrors: false },
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    tabMode: "shift",
    matchBrackets: true

  # These functions are scoped inside the handler so that they can easily
  # access the CodeMirror object.
  runCode = (worker) ->
    $('#output').text ''
    worker.postMessage cmd: 'run', code: codeArea.getValue()

  handleOutput = (text) ->
    output = $('#output');
    output.text(output.text() + text);

  handleError = (error) ->
    alert 'Failed! ' + error
    console.log error

  # Create HTML5 web worker to run code in a separate thread, so infinite
  # loops will not cause the entire browser to hang.
  worker = new Worker '/assets/internal/skulpt-worker.js'
  worker.addEventListener 'message', (e) =>
    data = e.data
    switch data.event
      when 'output'
        handleOutput data.text
      when 'success'
        alert 'success reported'
        # TODO Do something when the code successfully executes
        ;
      when 'error'
        alert 'failure reported'
        # TODO Do something appropriate when the code had an
        # error (syntax or runtime)
        handleError data.error
  , false

  # Register event handlers for widgets.
  $('#run').click (e) => runCode(worker)
