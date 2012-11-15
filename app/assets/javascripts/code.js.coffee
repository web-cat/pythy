# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Document ready handler:
$ ->
  # Convert the text area to a CodeMirror widget.
  codeArea = CodeMirror.fromTextArea $('#codearea')[0],
    mode: { name: "python", version: 3, singleLineStringErrors: false },
    lineNumbers: true,
    gutters: ["CodeMirror-linenumbers"]
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
    
    # Clear gutters markers
    codeArea.clearGutter("CodeMirror-linenumbers")

    # Clear syntax-highlighting
    for i in [0..codeArea.lineCount()] by 1
      codeArea.setLine(i, codeArea.getLine(i))

    # Clear line widgets
    if codeArea.lineInfo(0)? and codeArea.lineInfo(0).widgets?
      codeArea.removeLineWidget(codeArea.lineInfo(0).widgets[0])
            
    switch data.event    
      when 'output'
        handleOutput data.text
      when 'success'
        alert 'success reported'
        console.log(data)
        # TODO Do something when the code successfully executes
        ;
      when 'error'
        # alert 'failure reported'
        console.log(data.error)
        
        message = data.error.message
        type = data.error.type
        error = type + ": " + message
        
        if data.error.start? and data.error.start?
          start = { line : data.error.start.line-1, ch: data.error.start.ch }
          end = { line: data.error.end.line-1, ch: data.error.end.ch }
          marker = document.createElement("div")
          marker.className = "error-marker"
          marker.innerHTML = "● " + (start.line + 1)
          marker.title = error
          codeArea.markText(start, end, "syntax-highlight") 
          codeArea.setGutterMarker(start.line, "CodeMirror-linenumbers", marker)
        
        else # no line information
          node = document.createElement("div")
          node.innerHTML = error
          node.className = "error-marker"
          codeArea.addLineWidget(0, node, {above: true})
        
        # TODO Do something appropriate when the code had an
        # error (syntax or runtime)
        # handleError data.error
  , false

  # Register event handlers for widgets.
  $('#run').click (e) => runCode(worker)
