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

    $(window).resize => this._updateCodeSize()
    this._updateCodeSize()

    @codeArea.on 'cursorActivity', =>
      cur = @codeArea.getLineHandle(@codeArea.getCursor().line)
      if cur != @hlLine
        if @hlLine
          @codeArea.removeLineClass @hlLine, 'background', 'active-line'
        @hlLine = @codeArea.addLineClass(cur, 'background', 'active-line')

    @ignoreChange = false

    @console = new InteractiveConsole(this._handleInput)

    this._createWorker()

    # Register event handlers for widgets.
    $('#run').click (e) => this._runCode()
    $('#sync').click (e) => this._resync()
    $('#check').click (e) => this._checkCode()
    $('#start-over').click (e) => this._startOver()
    $('#sidebar-toggle').click this.toggleSidebar

    this._subscribe()

    setTimeout =>
      this._sendMessage data: message: 'ping'
    , (4 * 60 + 55) * 1000 # timeout is 5 min, so keep-alive every 4m55s

    if @isEditor
      this._trackChangesWithSaving()
    else
      this._trackChanges()


  #~ Private methods ..........................................................

  # ---------------------------------------------------------------
  _updateCodeSize: ->
    $('#code-area').height(
      $('#main-container').height() -
      parseInt($('#main-container-inner').css('paddingTop')) -
        $('#summary-area').height() - 50)


  # ---------------------------------------------------------------
  _sendMessage: (settings) ->
    settings.url = window.location.href
    settings.type ||= 'post'
    $.ajax settings


  # ---------------------------------------------------------------
  _trackChangesWithSaving: ->
    @timerHandle = null
    
    @codeArea.on "change", (_editor, change) =>
      if (!@ignoreChange)
        $('#check').attr 'disabled', 'disabled'
        if (@timerHandle)
          clearTimeout(@timerHandle)
        @timerHandle = setTimeout =>
          this._sendChangeRequest(this)
        , 500

    window.onbeforeunload = (e) =>
      #pythy.code.sendChangeRequest()
      this._sendMessage async: false, data: message: 'remove_user'
      null


  # ---------------------------------------------------------------
  _trackChanges: ->
    @codeArea.on "change", (_editor, change) =>
      if !@desynched && !@ignoreChange
        @desynched = true
        this._unsubscribeFromCode()
        this._sendMessage data: message: 'unsync'
        $('#sync').fadeIn('fast')
        $('#sync').tooltip('show')
        setTimeout =>
          $('#sync').tooltip('hide')
        , 8000

    window.onbeforeunload = (e) =>
      this._sendMessage async: false, data: message: 'remove_user'
      null


  # ---------------------------------------------------------------
  _resync: ->
    @desynched = false
    $('#sync').fadeOut('fast')
    $('#sync').tooltip('hide')
    this._subscribeToCode()
    this._sendMessage data: message: 'resync'


  # ---------------------------------------------------------------
  _checkCode: ->
    this._sendMessage data: message: 'check'


  # ---------------------------------------------------------------
  _startOver: ->
    pythy.confirm 'If you start over, the work you have done so far
      will be erased. Are you sure you want to do this?',
      title: 'Are you sure?'
      yesClass: 'btn-danger',
      onYes: => this._sendMessage data: message: 'start_over'


  # ---------------------------------------------------------------
  updateCode: (code, force) ->
    if force || !force && !@desynched
      @ignoreChange = true
      @codeArea.setValue code
      @ignoreChange = false


  # ---------------------------------------------------------------
  toggleSidebar: (force) ->
    sidebar = $('#sidebar')
    left = parseInt(sidebar.css('marginLeft'), 10)
    newLeft = if left == 0 then sidebar.outerWidth() else 0
    sidebar.animate marginLeft: newLeft, 100


  # ---------------------------------------------------------------
  _handleJuggernautMessage: (data) ->
    if data.javascript
      eval data.javascript


  # ---------------------------------------------------------------
  _subscribe: ->
    @jug = new Juggernaut

    $.ajaxSetup beforeSend: (xhr) =>
      xhr.setRequestHeader "X-Session-ID", @jug.sessionID

    this._subscribeToCode()

    if @isEditor
      @jug.subscribe "#{@channel}_users", this._handleJuggernautMessage
      @jug.subscribe "#{@channel}_results", this._handleJuggernautMessage


    this._sendMessage data: message: 'add_user'


  # -------------------------------------------------------------
  _subscribeToCode: ->
    @jug.subscribe "#{@channel}_code", this._handleJuggernautMessage


  # -------------------------------------------------------------
  _unsubscribeFromCode: ->
    @jug.unsubscribe "#{@channel}_code"


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
      this._clearErrors()
      @console.clear()
      @worker.postMessage cmd: 'run', code: @codeArea.getValue()


  # -------------------------------------------------------------
  _cleanup: ->
    this._setRunButtonStop(false)


  # -------------------------------------------------------------
  _handleOutput: (text) ->
    @console.output text


  # -------------------------------------------------------------
  _handleInput: (text) ->
    @worker.postMessage cmd: 'input', input: text


  # -------------------------------------------------------------
  _clearErrors: ->
    if @lastErrorWidget
      @codeArea.removeLineWidget @lastErrorWidget


  # -------------------------------------------------------------
  _handleError: (error) ->
    # Print the error at the bottom of the console.
    @console.error error

    # Add a widget to the code window showing the error.
    this._doNotTriggerChange =>
      message = error.message
      type = error.type
      #error = type + ": " + message

      if error.start
        error.end ||= error.start
        if error.start.line == error.end.line && error.start.ch == error.end.ch
          error.end.ch++

        start = line: error.start.line - 1, ch: error.start.ch
        end   = line: error.end.line - 1,   ch: error.end.ch

        marker = $('<div class="error-widget"></div>')
        #marker.innerHTML = "● " + (start.line + 1)
        marker.text "Error: #{error.message}"
        @lastErrorWidget = @codeArea.addLineWidget(start.line, marker[0])
#        @codeArea.markText(start, end, "syntax-highlight") 
#        @codeArea.setGutterMarker(start.line, "CodeMirror-linenumbers", marker)


    # Move the cursor to the error line in the code editor and give it
    # the focus.
    @codeArea.setCursor error.start.line - 1, error.start.ch
    @codeArea.focus()


  # -------------------------------------------------------------
  _doNotTriggerChange: (func) ->
    @ignoreChange = true
    func()
    @ignoreChange = false


  # -------------------------------------------------------------
  _createWorker: ->
    # Create HTML5 web worker to run code in a separate thread, so infinite
    # loops will not cause the entire browser to hang.
    @worker = new Worker '/assets/internal/skulpt-worker.js'

    @worker.addEventListener 'message', (e) =>
      data = e.data

      switch data.event
        when 'log'
          console.log data.args
        when 'input'
          @console.promptForInput data.prompt
        when 'output'
          this._handleOutput data.text
        when 'success'
          @console.success()
          this._cleanup()
        when 'error'
          this._handleError data.error
          this._cleanup()
    , false


# -------------------------------------------------------------
class InteractiveConsole

  # -------------------------------------------------------------
  constructor: (onInput) ->
    @console_content = $("#console-content")
    @visible = false
    
    @inputField = $('<input type="text"/>')
    @inputField.on 'change', =>
      @inputField.remove()
      onInput @inputField.val()

    this._createNewLine()

    $('#console-toggle').click this.toggleConsole


  # -------------------------------------------------------------
  toggleConsole: ->
    sidebar = $('#console')
    top = parseInt(sidebar.css('marginTop'), 10)
    newTop = if top == 0 then sidebar.outerHeight() else 0
    sidebar.animate marginTop: newTop, 100
    @visible = (newTop == 0)


  # -------------------------------------------------------------
  clear: ->
    @console_content.empty()
    this._createNewLine()


  # -------------------------------------------------------------
  output: (text) ->
    lines = text.split('\n')

    firstLine = lines.shift()
    this._addToCurrentLine firstLine

    for line in lines
      this._createNewLine()
      this._addToCurrentLine line

    this.toggleConsole() unless @visible
    

  # -------------------------------------------------------------
  error: (error) ->
    this._createNewLine('text-error')
    this._addToCurrentLine """
      Your program terminated prematurely because the following error
      occurred on line #{error.start.line}: #{error.message}
      """


  # -------------------------------------------------------------
  success: ->
    this._createNewLine('text-success')
    this._addToCurrentLine "Your program finished successfully."


  # -------------------------------------------------------------
  promptForInput: (prompt) ->
    @currentLine.append @inputField


  # -------------------------------------------------------------
  _createNewLine: (classes) ->
    @currentLine = $('<div class="line"></div>')
    @currentLine.addClass classes if classes
    @console_content.append @currentLine


  # -------------------------------------------------------------
  _addToCurrentLine: (text) ->
    @currentLine.text @currentLine.text() + text


# Export
window.CodeController = CodeController
window.InteractiveConsole = InteractiveConsole
