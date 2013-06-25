class CodeController

  # -------------------------------------------------------------
  constructor: () ->
    $codearea = $('#codearea')

    @channel = $codearea.data('channel')
    @isEditor = ($codearea.data('editor') == true)
    @mediaKey = $codearea.data('user-media-key')

    # Convert the text area to a CodeMirror widget.
    @codeArea = CodeMirror.fromTextArea $codearea[0],
      mode: { name: "python", version: 3, singleLineStringErrors: false },
      lineNumbers: true,
      gutters: ["CodeMirror-linenumbers"]
      indentUnit: 2,
      tabSize: 2,
      indentWithTabs: false,
      matchBrackets: true,
      extraKeys: { Tab: (cm) -> cm.replaceSelection('  ', 'end') }

    # Highlight the line the cursor is currently on (and kill the
    # highlighting when the editor doesn't have the focus).
    @codeArea.on 'cursorActivity', =>
      cur = @codeArea.getLineHandle(@codeArea.getCursor().line)
      if cur != @hlLine
        if @hlLine
          @codeArea.removeLineClass @hlLine, 'background', 'active-line'
        @hlLine = @codeArea.addLineClass(cur, 'background', 'active-line')

    @codeArea.on 'blur', =>
      if @hlLine
        @codeArea.removeLineClass @hlLine, 'background', 'active-line'

    @ignoreChange = false
    @ignoreNextHashChange = false

    @console = new InteractiveConsole()

    this._initializeSkulpt()

    $('#check').data('loading-text', '<i class="icon-spinner icon-spin"></i>')

    # Register event handlers for widgets.
    $('#run').click (e) => this._runCode()
    $('#sync').click (e) => this._resync()
    $('#check').click (e) => this._checkCode()
    $('#start-over').click (e) => this._startOver()
    $('#media').click (e) => this._openMediaLibrary()
    $(window).hashchange => this._hashChange()

    window.setInterval (=> this._updateHistoryTimestamps()), 1000

    #$('#dock .nav-tabs a').on 'shown', (e) => this._dockTabShown(e)
    $('#history .next-page').appear()
    $(document.body).on 'appear', '#history .next-page', => this._loadNextHistoryPage()
    this._loadNextHistoryPage()

    this._subscribe()
    this._updateHistorySelection(window.location.hash)

    setTimeout =>
      this._sendMessage data: message: 'ping'
    , (4 * 60 + 55) * 1000 # timeout is 5 min, so keep-alive every 4m55s

    if @isEditor
      this._trackChangesWithSaving()
    else
      this._trackChanges()


  #~ Private methods ..........................................................

  # ---------------------------------------------------------------
  _dockTabShown: (e) ->
    if e.target.hash == '#history'
      if $('#history-table tbody tr').length == 0
        this._loadNextHistoryPage()


  # ---------------------------------------------------------------
  _loadNextHistoryPage: ->
    if @loading
      @pendingHistoryLoad = true
    else
      @loading = true
      skip = $('#history-table tbody tr').length
      $('#history .next-page i').addClass 'icon-spin'
      this._sendMessage data: message: 'history', start: skip


  # ---------------------------------------------------------------
  nextHistoryPageLoaded: ->
    $('#history .next-page i').removeClass 'icon-spin'
    @loading = false
    if @pendingHistoryLoad
      this._loadNextHistoryPage()


  # ---------------------------------------------------------------
  _updateHistoryTimestamps: ->
    if $('#history').hasClass('active')
      $('#history-table tr').each ->
        $this = $(this)
        date = new Date($this.data('date'))
        $('.relative-date', $this).text "(#{date.toRelativeTime(60000)})"


  # ---------------------------------------------------------------
  _isQuote: (ch) ->
    ch == '"' || ch == "'"


  # ---------------------------------------------------------------
  _openMediaLibrary: ->
    window.pythy.showMediaModal
      mediaLinkClicked: (link) => this._insertHrefIntoCode(link)


  # ---------------------------------------------------------------
  _insertHrefIntoCode: (link) ->
    clientHost = "#{window.location.protocol}//#{window.location.host}"

    url = $(link).attr('href')
    if url[0] == '/'
      url = clientHost + url

    cursor = @codeArea.getCursor()

    if @codeArea.somethingSelected()
      @codeArea.replaceSelection(url)
    else
      # Let's try to be smart about quoting to help the student out. Look
      # around the cursor for quotes that they've already typed; if some
      # are found, match them automatically. Otherwise surround the URL
      # with quotes of its own.

      before = { line: cursor.line, ch: cursor.ch - 1 }
      after = { line: cursor.line, ch: cursor.ch + 1 }

      if before.ch >= 0
        charBefore = @codeArea.getRange(before, cursor)
        charAfter = @codeArea.getRange(cursor, after)

        if charBefore == charAfter && this._isQuote(charBefore)
          @codeArea.replaceSelection("#{url}")
        else if this._isQuote(charBefore)
          @codeArea.replaceSelection("#{url}#{charBefore}")
        else
          @codeArea.replaceSelection("'#{url}'")
      else
        @codeArea.replaceSelection("'#{url}'")

    $('#media_library_modal').modal 'hide'
    @codeArea.focus()


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
    
    @codeArea.on 'change', (_editor, change) =>
      if !@ignoreChange
        $('#check').attr 'disabled', 'disabled'
        if (@timerHandle)
          clearTimeout(@timerHandle)
        @timerHandle = setTimeout =>
          this._sendChangeRequest(this)
        , 500

    window.onbeforeunload = (e) =>
      this._sendMessage async: false, data: message: 'remove_user'
      null


  # ---------------------------------------------------------------
  _trackChanges: ->
    @codeArea.on 'change', (_editor, change) =>
      if !@desynched && !@ignoreChange
        @desynched = true
        this._unsubscribeFromCode()
        this._sendMessage data: message: 'unsync'
        $('#sync-button-group').fadeIn('fast')
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
    $('#sync-button-group').fadeOut('fast')
    $('#sync').tooltip('hide')
    this._subscribeToCode()
    this._sendMessage data: message: 'resync'


  # ---------------------------------------------------------------
  _checkCode: ->
    unless $('#check').attr('disabled')
      $('#check').tooltip('hide')
      $('#check').button('loading')
      this._sendMessage data: message: 'check'


  # ---------------------------------------------------------------
  _startOver: ->
    pythy.confirm 'If you start over, the work you have done so far
      will be erased. Are you sure you want to do this?',
      title: 'Are you sure?'
      yesClass: 'btn-danger',
      onYes: => this._sendMessage data: message: 'start_over'


  # ---------------------------------------------------------------
  updateCode: (code, force, newHistoryRow, amend) ->
    if force || !force && !@desynched
      @ignoreChange = true
      @codeArea.setValue code
      @ignoreChange = false

    if newHistoryRow
      this.updateHistory(newHistoryRow, amend)


  # ---------------------------------------------------------------
  updateHistory: (newHistoryRow, amend) ->
    row = $(newHistoryRow)

    if amend
      $('#history-table tbody tr:first-child').replaceWith(row)
    else
      row.hide().prependTo('#history-table tbody').fadeIn()

    @ignoreNextHashChange = true
    window.location.hash = ''
    this._updateHistorySelection()


  # ---------------------------------------------------------------
  _jugMessageHandler: (self) ->
    (data) ->
      if data.javascript
        eval data.javascript
      else if data.message
        self._sendMessage data: data


  # ---------------------------------------------------------------
  _subscribe: ->
    @jug = window.pythy.juggernaut()

    this._subscribeToCode()

    if @isEditor
      @jug.subscribe "#{@channel}_users", this._jugMessageHandler(this)
      @jug.subscribe "#{@channel}_results", this._jugMessageHandler(this)

    data = { message: 'add_user' }
    if window.location.hash
      data.sha = unescape(window.location.hash.substring(1))

    this._sendMessage data: data


  # -------------------------------------------------------------
  _hashChange: ->
    if @ignoreNextHashChange
      @ignoreNextHashChange = false
    else
      data = { message: 'hash_change' }
      if window.location.hash && window.location.hash.length > 0
        data.sha = unescape(window.location.hash.substring(1))

      this._sendMessage data: data
      this._updateHistorySelection(data.sha)


  # -------------------------------------------------------------
  _updateHistorySelection: (sha) ->
    if sha && sha[0] == '#'
      sha = sha[1..]

    $("#history-table tr.info").removeClass('info')

    if sha
      $("#history-table a[href='##{sha}']").closest('tr').addClass('info')
    else
      $("#history-table tr:first-child").addClass('info')
      $('#history').animate scrollTop: 0, 100


  # -------------------------------------------------------------
  _subscribeToCode: ->
    @jug.subscribe "#{@channel}_code", this._jugMessageHandler(this)


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
        data('running', true).html('<i class="icon-spinner icon-large icon-spin"></i>')
      $('#console-spinner').show()
    else
      $('#run').removeClass('btn-danger').addClass('btn-success').
        data('running', false).html('<i class="icon-play"></i>')
      $('#console-spinner').hide()


  # -------------------------------------------------------------
  _runCode: ->
    if $('#run').data('running')
      @console.terminate()
      this._cleanup()
    else
      Sk.reset()
      this._setRunButtonStop(true)
      this._clearErrors()
      @console.clear()
      @console.toggleConsole()
      code = @codeArea.getValue()
      starter =     => Sk.importMainWithBody("<stdin>", false, code)
      error   = (e) => this._handleException(e)
      success =     => @console.success(); this._cleanup()
      Sk.runInBrowser starter, success, error


  # -------------------------------------------------------------
  _cleanup: ->
    Sk.cancelInBrowser()
    Sk.reset()
    this._setRunButtonStop(false)


  # -------------------------------------------------------------
  _handleOutput: (text) ->
    @console.output text


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

        widget = $('<div class="error-widget"></div>')
        widget.text "Error: #{error.message}"
        @lastErrorWidget = @codeArea.addLineWidget(start.line, widget[0])
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
  _handleException: (e) ->
    if e.tp$name
      errorInfo =
        type: e.tp$name,
        message: e.args.v[0].v

      if e.args.v.length > 3
        if typeof(e.args.v[3]) is 'number'
          errorInfo.start =
            line: e.args.v[3],
            ch: e.args.v[4]
        else
          errorInfo.start =
            line: e.args.v[3][0][0],
            ch: e.args.v[3][0][1]
          errorInfo.end =
            line: e.args.v[3][1][0],
            ch: e.args.v[3][1][1]
      else
        errorInfo.start =
          line: Sk.currLineNo,
          ch: Sk.currColNo
    else
      errorInfo =
        type: 'Internal error (' + e.name + ')',
        message: e.message

    this._handleError errorInfo
    this._cleanup()


  # -------------------------------------------------------------
  _initializeSkulpt: ->
    Sk.configure {
      output:       (text) => this._skOutput(text),
      input:        (prompt) => this._skInput(prompt),
      read:         (file) => this._skRead(file),
      transformUrl: (url) => this._skTransformUrl(url)
    }

    # Configure the media comp module's foreign function interface.
    window.mediacompffi = {
      customizeMediaURL: (url) =>
        this._mcCustomizeMediaURL(url)
      writePictureTo: (dataURL, path, continueWith) =>
        this._mcWritePictureTo(dataURL, path, continueWith)
    }


  # -------------------------------------------------------------
  _skOutput: (text) ->
    this._handleOutput text


  # -------------------------------------------------------------
  _skInput: (prompt) ->
    Sk.future (continueWith) =>
      @console.promptForInput prompt, (text) => continueWith(text)


  # -------------------------------------------------------------
  _skRead: (file) ->
    if Sk.builtinFiles is undefined || Sk.builtinFiles['files'][file] is undefined
      throw "File not found: '" + x + "'"
    else
      Sk.builtinFiles['files'][file]


  # -------------------------------------------------------------
  _skTransformUrl: (url) ->
    encodedUrl = encodeURIComponent(url)
    clientHost = "#{window.location.protocol}//#{window.location.host}"

    # If the URL is to the same host, just let it go through the same;
    # otherwise, wrap it in a proxy request
    if url.indexOf(clientHost) == 0
      url
    else
      "#{window.location.protocol}//#{window.location.host}/proxy?url=#{encodedUrl}"


  # -------------------------------------------------------------
  _mcWritePictureTo: (dataURL, path, continueWith) ->
    window.pythy.uploadFileFromDataURL(path, dataURL).done (e, data) ->
      continueWith(null)


  # -------------------------------------------------------------
  _mcCustomizeMediaURL: (url) ->
    if /^https?:\/\//.test(url)
      url
    else
      # If it doesn't have a protocol, then treat it as if it's a filename of
      # something in the media library.
      "#{window.location.protocol}//#{window.location.host}/m/u/#{@mediaKey}/#{url}"


# -------------------------------------------------------------
class InteractiveConsole

  # -------------------------------------------------------------
  constructor: (onInput) ->
    @console_content = $("#console-content")
    @visible = false
    
    @inputField = $('<input type="text" class="input-xlarge"
      placeholder=" Type something..."/>')

    this._createNewLine()

    $('#console-spinner').hide()


  # -------------------------------------------------------------
  toggleConsole: (action) ->
    $('#dock a[href="#console"]').tab('show');


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

    this.toggleConsole('open')
    

  # -------------------------------------------------------------
  error: (error) ->
    this._createNewLine('text-error')

    if error.start
      this._addToCurrentLine """
        Your program ended prematurely because the following error
        occurred on line #{error.start.line}: #{error.message}
        """
    else
      this._addToCurrentLine """
        Your program ended prematurely because the following error
        occurred: #{error.message}
        """


  # -------------------------------------------------------------
  success: ->
    this._createNewLine('text-success')
    this._addToCurrentLine "Your program finished successfully."
    
    # TODO Implement interactive console
    #" You can now interactively type Python statements below to further test your code."
    #
    #this._createNewLine()
    #askCommand = =>
    #  this.promptForInput '', askCommand
    #
    #this.promptForInput '', askCommand


  # -------------------------------------------------------------
  terminate: ->
    @inputField.remove()
    this._createNewLine('text-warning')
    this._addToCurrentLine "You manually ended your program."


  # -------------------------------------------------------------
  promptForInput: (prompt, callback) ->
    this.toggleConsole('open')
    this._addToCurrentLine prompt
    @inputField.val('')
    @currentLine.append @inputField
    @inputField.focus()

    @inputField.unbind('change').change =>
      text = @inputField.val()
      @inputField.remove()
      this._addToCurrentLine(text, 'text-info')
      this._createNewLine()
      callback text


  # -------------------------------------------------------------
  _createNewLine: (classes) ->
    @currentLine = $('<div class="line"></div>')
    @currentLine.addClass classes if classes
    @console_content.append @currentLine

    $console = $('#console')
    $console.scrollTop($console[0].scrollHeight);


  # -------------------------------------------------------------
  _addToCurrentLine: (text, classes) ->
    if classes
      newSpan = $("<span class=\"#{classes}\"></span>").text(text)
      @currentLine.append(newSpan)
    else
      @currentLine.append($('<div/>').text(text).html())


# Export
window.CodeController = CodeController
window.InteractiveConsole = InteractiveConsole

$ ->
  window.codeController = new CodeController()

  adjustCodeTop = ->
    codeTop = $('#flashbar').height() + 38
    $('#code-area').css 'top', "#{codeTop}px"
    $('#action-bar').css 'top', "#{codeTop}px"

  $('#flashbar .flash').on 'hidden', adjustCodeTop
  adjustCodeTop()
