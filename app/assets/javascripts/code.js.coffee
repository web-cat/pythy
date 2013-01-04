# Document ready handler:
pythy.code = {}

pythy.code.sendChangeRequest = () ->
  value = pythy.code.codeArea.getValue()
  $.ajax type: 'PUT', url: window.location.href, data: { code: value }

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
  pythy.code.codeArea = codeArea

  # These functions are scoped inside the handler so that they can easily
  # access the CodeMirror object.
  setRunButtonStop = (stop) ->
    if stop
      $('#run').removeClass('btn-success').addClass('btn-danger').
        data('running', true).html('<i class="icon-stop"></i> Stop')
    else
      $('#run').removeClass('btn-danger').addClass('btn-success').
        data('running', false).html('<i class="icon-play"></i> Run')

  runCode = () ->
    if $('#run').data('running')
      pythy.code.worker.terminate()
      cleanup()
      createWorker()
    else
      setRunButtonStop(true)
      $('#output').text ''
      pythy.code.worker.postMessage cmd: 'run', code: codeArea.getValue()

  cleanup = () ->
    setRunButtonStop(false)

  handleOutput = (text) ->
    output = $('#output');
    output.text(output.text() + text);

  handleError = (error) ->
    alert 'Failed! ' + error
    console.log error

  createWorker = () ->
    # Create HTML5 web worker to run code in a separate thread, so infinite
    # loops will not cause the entire browser to hang.
    worker = new Worker '/assets/internal/skulpt-worker.js'
    pythy.code.worker = worker

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
          console.log(data)
          # TODO Do something when the code successfully executes
          ;
          cleanup()
        when 'error'
          # alert 'failure reported'
          console.log(data.error)
          
          message = data.error.message
          type = data.error.type
          error = type + ": " + message
          
          if data.error.start? and data.error.end?
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
          cleanup()
    , false

  createWorker()

  # Register event handlers for widgets.
  $('#run').click (e) => runCode()

  jug = new Juggernaut
  $.ajaxSetup beforeSend: (xhr) ->
    xhr.setRequestHeader "X-Session-ID", jug.sessionID

  jug.subscribe "code_updated", (data) ->
    pythy.code.changeWasRemote = true
    codeArea.setValue data.code
    pythy.code.changeWasRemote = false

  # jug.subscribe "user_added", (data) ->
  #   document.title = '(' + data.users + ') Pythy'

  # jug.subscribe "user_removed", (data) ->
  #   document.title = '(' + data.users + ') Pythy'

  $.post window.location.href, message: 'add_user'


# ---------------------------------------------------------------
pythy.code.startAutoSaving = () ->
  pythy.code.changeWasRemote = false
  timerHandle = null
  pythy.code.codeArea.on "change", (_editor, change) ->
    if (!pythy.code.changeWasRemote)
      if (timerHandle)
        clearTimeout(timerHandle)
      timerHandle = setTimeout(pythy.code.sendChangeRequest, 500)

  window.onbeforeunload = (e) ->
    pythy.code.sendChangeRequest()
    #$.ajax "/code/remove_user", data: { username: username }
    null
