class CodeController

  # -------------------------------------------------------------
  constructor: (@channel, @isEditor) ->
    # Convert the text area to a CodeMirror widget.
    @codeArea = CodeMirror.fromTextArea $('#codearea')[0],
      mode: { name: "python", version: 3, singleLineStringErrors: false },
      lineNumbers: true,
      gutters: ["CodeMirror-linenumbers"]
      indentUnit: 2,
      tabSize: 2,
      tabMode: "shift",
      matchBrackets: true

    this._createWorker()

    # Register event handlers for widgets.
    $('#run').click (e) => this._runCode()
    $('#sync').click (e) => this._resync()

    this._subscribe()

    if @isEditor
      this._trackChangesWithSaving()
    else
      this._trackChanges()


  #~ Private methods ..........................................................

  # ---------------------------------------------------------------
  _trackChangesWithSaving: ->
    @changeWasRemote = false
    timerHandle = null
    
    @codeArea.on "change", (_editor, change) =>
      if (!@changeWasRemote)
        if (timerHandle)
          clearTimeout(timerHandle)
        timerHandle = setTimeout =>
          this._sendChangeRequest(this)
        , 500

    window.onbeforeunload = (e) ->
      #pythy.code.sendChangeRequest()
      #$.ajax "/code/remove_user", data: { username: username }
      null


  # ---------------------------------------------------------------
  _trackChanges: ->
    @changeWasRemote = false
    
    @codeArea.on "change", (_editor, change) =>
      if !@desynched && !@changeWasRemote
        @desynched = true
        $('#sync').fadeIn('fast')
        $('#sync').tooltip('show')
        setTimeout =>
          $('#sync').tooltip('hide')
        , 8000

    window.onbeforeunload = (e) ->
      #$.ajax "/code/remove_user", data: { username: username }
      null


  # ---------------------------------------------------------------
  _resync: ->
    @desynched = false
    $('#sync').fadeOut('fast')
    $('#sync').tooltip('hide')
    $.post window.location.href, message: 'resync'


  # ---------------------------------------------------------------
  _subscribe: ->
    @jug = new Juggernaut
    $.ajaxSetup beforeSend: (xhr) =>
      xhr.setRequestHeader "X-Session-ID", @jug.sessionID

    @jug.subscribe @channel, (data) =>
      if data.action == 'code_updated'
        unless @desynched
          @changeWasRemote = true
          @codeArea.setValue data.code
          @changeWasRemote = false
      else if data.action == 'user_added'
        ;
      else if data.action == 'user_removed'
        ;

    $.post window.location.href, message: 'add_user'


  # -------------------------------------------------------------
  _sendChangeRequest: ->
    value = @codeArea.getValue()
    $.ajax type: 'PUT', url: window.location.href, data: { code: value }


  # -------------------------------------------------------------
  _setRunButtonStop: (stop) ->
    if stop
      $('#run').removeClass('btn-success').addClass('btn-danger').
        data('running', true).html('<i class="icon-stop"></i> Stop')
    else
      $('#run').removeClass('btn-danger').addClass('btn-success').
        data('running', false).html('<i class="icon-play"></i> Run')


  # -------------------------------------------------------------
  _runCode: ->
    if $('#run').data('running')
      @worker.terminate()
      this._cleanup()
      this._createWorker()
    else
      this._setRunButtonStop(true)
      $('#output').text ''
      @worker.postMessage cmd: 'run', code: @codeArea.getValue()


  # -------------------------------------------------------------
  _cleanup: ->
    this._setRunButtonStop(false)


  # -------------------------------------------------------------
  _handleOutput: (text) ->
    output = $('#output');
    output.text(output.text() + text);


  # -------------------------------------------------------------
  _handleError: (error) ->
    alert 'Failed! ' + error
    console.log error


  # -------------------------------------------------------------
  _createWorker: ->
    # Create HTML5 web worker to run code in a separate thread, so infinite
    # loops will not cause the entire browser to hang.
    @worker = new Worker '/assets/internal/skulpt-worker.js'

    @worker.addEventListener 'message', (e) =>
      data = e.data
      
      # Clear gutters markers
      @codeArea.clearGutter("CodeMirror-linenumbers")

      # Clear syntax-highlighting
      for i in [0..@codeArea.lineCount()] by 1
        @codeArea.setLine(i, @codeArea.getLine(i))

      # Clear line widgets
      if @codeArea.lineInfo(0)? and @codeArea.lineInfo(0).widgets?
        @codeArea.removeLineWidget(@codeArea.lineInfo(0).widgets[0])
              
      switch data.event
        when 'output'
          this._handleOutput data.text
        when 'success'
          console.log(data)
          # TODO Do something when the code successfully executes
          ;
          this._cleanup()
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
            @codeArea.markText(start, end, "syntax-highlight") 
            @codeArea.setGutterMarker(start.line, "CodeMirror-linenumbers", marker)
          
          else # no line information
            node = document.createElement("div")
            node.innerHTML = error
            node.className = "error-marker"
            @codeArea.addLineWidget(0, node, {above: true})

          # TODO Do something appropriate when the code had an
          # error (syntax or runtime)
          # handleError data.error
          this._cleanup()
    , false


# Export
window.CodeController = CodeController
