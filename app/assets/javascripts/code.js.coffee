class CodeController
  constructor: (opts) ->
    {$codearea, @workspace} = opts

    opts.codeController = this
    @console = new InteractiveConsole(opts)

    @_initializeData($codearea)
    @_setupDateShim()
    @_createCodeMirrorWidget($codearea)
    @_initializeSkulpt()
    @_setLoading()
    @_registerEventHandlers()
    @_loadNextHistoryPage()
    @_subscribe()
    @_updateHistorySelection(window.location.hash)
    @_setupPeriodPing()
    @supportsLocalStorage = typeof(Storage) isnt "undefined"

    if @isEditor then @_trackChangesWithSaving() else @_trackChanges()

    if $codearea.data('needs-environment')
      @_sendMessage(data: {message: 'prompt_for_environment'})

  # XXX Why do we need this?
  _setupPeriodPing : () ->
    @periodicPingTimer = setInterval () =>
      @_sendMessage({data: {message: 'ping'}})
    , (4 * 60 + 55) * 1000 # timeout is 5 min, so keep-alive every 4m55s

  _initializeData : ($codearea) ->
    @channel  = $codearea.data('channel')
    @isEditor = $codearea.data('editor')
    @mediaKey = $codearea.data('user-media-key')
    @localStoragePath = $codearea.data('user-email') + $codearea.data('path')
    @updated_at = parseInt($codearea.data('updated-at'))
    @ignoreChange = false
    @ignoreNextHashChange = false

    @runButton = $('#run')
    @consoleSpinnerElement = $('#console-spinner')

  _setupDateShim : () ->
    # Date shim for old browsers.
    if not Date.now then Date.now = () -> new Date().getTime()

  _setLoading : () ->
    $('#check').data('loading-text', '<i class="fa fa-spinner fa-spin"></i>')

  _createCodeMirrorWidget : ($codearea) ->
    @codeArea = CodeMirror.fromTextArea($codearea[0],
      mode :
        name : "python"
        version : 3
        singleLineStringErrors: false
      lineNumbers : true
      gutters : ["CodeMirror-linenumbers"]
      indentUnit : 2
      tabSize : 2
      indentWithTabs : false
      matchBrackets : true
      extraKeys :
        Tab: (cm) -> cm.replaceSelection('  ', 'end')
    )
    @_registerCodeAreaEventHandlers()

  _registerCodeAreaEventHandlers : () ->
    # Highlight the line the cursor is currently on (and kill the
    # highlighting when the editor doesn't have the focus).
    @codeArea.on 'cursorActivity', () =>
      cur = @codeArea.getLineHandle(@codeArea.getCursor().line)
      return if cur is @hlLine
      @codeArea.removeLineClass(@hlLine, 'background', 'active-line') if @hlLine
      @hlLine = @codeArea.addLineClass(cur, 'background', 'active-line')

    @codeArea.on 'blur', () =>
      @codeArea.removeLineClass(@hlLine, 'background', 'active-line') if @hlLine


  _registerEventHandlers : () ->
    $('#run').click(@_runCode)
    $('#sync').click(@_resync)
    $('#check').click(@_checkCode)
    $('#media').click(@_openMediaLibrary)
    $('#change-environment').click (e) =>
      @_sendMessage({data: {message: 'prompt_for_environment'}})
    $(window).hashchange(@_hashChange)
    $('#history-table .next-page').appear()
    $(document.body).on('appear', '#history-table .next-page', @_loadNextHistoryPage)

  _loadNextHistoryPage : () =>
    if @loading then @pendingHistoryLoad = true
    else
      @loading = true
      # Show as loading (rotate the icon in the footer)
      $('#history-table .next-page i').addClass('fa-spin')
      # Send a message to the server to supply a list of all 
      # previous scratchpad commits for this student
      skip = $('#history-table tbody tr').length
      @_sendMessage({data: {message: 'history', start: skip}})

  _isQuote: (ch) ->
    ch is '"' or ch is "'"

  _openMediaLibrary : () =>
    window.pythy.showMediaModal({mediaLinkClicked: @_insertHrefIntoCode})

  _insertHrefIntoCode: (link) =>
    clientHost = "#{window.location.protocol}//#{window.location.host}"

    url = $(link).attr('href')
    if url[0] == '/' then url = clientHost + url

    cursor = @codeArea.getCursor()

    if @codeArea.somethingSelected() then @codeArea.replaceSelection(url)
    else
      # Let's try to be smart about quoting to help the student out. Look
      # around the cursor for quotes that they've already typed; if some
      # are found, match them automatically. Otherwise surround the URL
      # with quotes of its own.

      before =
        line : cursor.line
        ch   : cursor.ch - 1

      after =
        line : cursor.line
        ch   : cursor.ch + 1

      if before.ch >= 0
        charBefore = @codeArea.getRange(before, cursor)
        charAfter = @codeArea.getRange(cursor, after)

        if charBefore == charAfter && @_isQuote(charBefore)
          @codeArea.replaceSelection("#{url}")
        else if @_isQuote(charBefore)
          @codeArea.replaceSelection("#{url}#{charBefore}")
        else
          @codeArea.replaceSelection("'#{url}'")
      else
        @codeArea.replaceSelection("'#{url}'")

    $('#media_library_modal').modal('hide')
    @codeArea.focus()

  _sendMessage : (settings) ->
    settings.url = window.location.href
    settings.type ||= 'post'
    $.ajax(settings)

  _trackChangesWithSaving : () ->
    timerHandle = null
    
    @codeArea.on 'change', (_editor, change) =>
      unless @ignoreChange
        $('#check').attr('disabled', 'disabled')
        $('#save-state-icon').html('<i class="fa fa-ban"></i>')
        $('#save-state-message').html('wait')
        if (timerHandle) then clearTimeout(timerHandle)
        timerHandle = setTimeout(@_sendChangeRequest, 5000)

    @_removeUserAtTheEnd()

  _removeUserAtTheEnd : () ->
      window.onbeforeunload = (e) =>
        @_sendMessage
          async : false
          data  : {message : 'remove_user'}
        # NOTE: We have to explicity return null here, otherwise
        # the browser will pop up an alert that asks the user
        # if they are sure about navigating away from the page
        return null

  _trackChanges : () ->
    @codeArea.on 'change', (_editor, change) =>
      if not @desynched and not @ignoreChange
        @desynched = true
        @_unsubscribeFromCode()
        @_sendMessage({data: {message: 'unsync'}})
        $('#sync-button-group').fadeIn('fast')
        $('#sync').tooltip('show')
        setTimeout((() -> $('#sync').tooltip('hide')), 8000)

    @_removeUserAtTheEnd()

  _resync: () =>
    @desynched = false
    $('#sync-button-group').fadeOut('fast')
    $('#sync').tooltip('hide')
    @_subscribeToCode()
    @_sendMessage({data : {message: 'resync'}})

  _checkCode: () =>
    unless $('#check').attr('disabled')
      $('#check').tooltip('hide')
      $('#check').button('loading')
      @_sendMessage({data : {message: 'check'}})

  setPreamble : (preamble) ->
    @preamble = preamble
    @preambleLines = @preamble.split('\n').length - 1

  updateCode: (code, force, newHistoryRow, amend, initial = false) ->
    if force or not force and not @desynched
      @ignoreChange = true
      
      loadFromLocal = false
      
      # Load code from local storage if more currrent.
      if @supportsLocalStorage
        localTimestamp = window.localStorage[@localStoragePath + '-timestamp']
        if localTimestamp then localTimestamp = parseInt(localTimestamp)
  
        if initial && localTimestamp && localTimestamp > @updated_at
          loadFromLocal = true
          code = window.localStorage[@localStoragePath]
          $('#save-state-icon').html('<i class="fa fa-warning"></i>')
          $('#save-state-message').html('local')
          # Remove the local storage item.
          window.localStorage.removeItem(@localStoragePath + '-timestamp')
          window.localStorage.removeItem(@localStoragePath)
        
      @codeArea.setValue(code)
      
      @ignoreChange = false
      
      # Try to update the code in the server if it was loaded from local storage.
      @_sendChangeRequest() if loadFromLocal

    if newHistoryRow then @updateHistory(newHistoryRow, amend)

    clearTimeout(@overlayDelay)
    @overlayDelay = null
    $('#code-loading-overlay').fadeOut duration: 50

  nextHistoryPageLoaded : () ->
    $('#history-table .next-page i').removeClass('fa-spin')
    @loading = false
    if @pendingHistoryLoad then @_loadNextHistoryPage()

  updateHistory : (newHistoryRow, amend) ->
    row = $(newHistoryRow)

    if amend then $('#history-table tbody tr:first-child').replaceWith(row)
    else row.hide().prependTo('#history-table tbody').fadeIn()

    @ignoreNextHashChange = true
    window.location.hash = ''
    @_updateHistorySelection()

  _jugMessageHandler : (self) ->
    (data) ->
      if data.javascript then eval(data.javascript)
      else if data.message then self._sendMessage({data: data})

  _subscribe : () ->
    @jug = window.pythy.juggernaut()

    @_subscribeToCode()

    if @isEditor
      @jug.subscribe "#{@channel}_users", @_jugMessageHandler(this)
      @jug.subscribe "#{@channel}_results", @_jugMessageHandler(this)

    data = { message: 'add_user' }
    if window.location.hash
      data.sha = unescape(window.location.hash.substring(1))

    @_sendMessage({data: data})

  _hashChange : () =>
    if @ignoreNextHashChange then @ignoreNextHashChange = false
    else
      @overlayDelay = setTimeout () ->
        $('#code-loading-overlay').fadeIn()
      , 250

      data = {message: 'hash_change'}
      if window.location.hash && window.location.hash.length > 0
        data.sha = unescape(window.location.hash.substring(1))

      @_sendMessage({data: data})
      @_updateHistorySelection(data.sha)

  _updateHistorySelection: (sha) ->
    if sha && sha[0] == '#' then sha = sha[1..]

    $("#history-table tr.info").removeClass('info')

    if sha
      $("#history-table a[href='##{sha}']").closest('tr').addClass('info')
    else
      $("#history-table tr:first-child").addClass('info')
      $('#history-table').animate scrollTop: 0, 100

  _subscribeToCode: () ->
    @jug.subscribe("#{@channel}_code", @_jugMessageHandler(this))

  _unsubscribeFromCode: () ->
    @jug.unsubscribe("#{@channel}_code")

  _sendChangeRequest: () =>
    codeValueToSave = @codeArea.getValue()
    
    # Save times-out in 8 seconds.
    $.ajax
      type : 'PUT'
      url  : window.location.href
      timeout : 8000
      data :
        code : codeValueToSave
        timestamp : Math.round(timestamp: Date.now() / 1000)
      error : (xmlhttprequest, status, message) ->
        @_saveAjaxError(xmlhttprequest, status, message, codeValueToSave)
      context : this
    
    $('#save-state-icon').html('<i class="fa fa-spinner fa-spin"></i>')
    $('#save-state-message').html('saving')

  _saveAjaxError: (xmlhttprequest, status, message, codeValueToSave) ->
    # There was an error saving the code.
    # Try to abort the ajax request if possible.
    xmlhttprequest.abort()
    
    # Try to save in local storage instead.
    if @supportsLocalStorage
      window.localStorage[@localStoragePath + '-timestamp'] = Math.round(Date.now() / 1000)
      window.localStorage[@localStoragePath] = codeValueToSave
      $('#save-state-icon').html('<i class="fa fa-warning"></i>')
      $('#save-state-message').html('local')
    else
      $('#save-state-icon').html('<i class="fa fa-times"></i>')
      $('#save-state-message').html('unsaved')
      
  _setRunButtonState: (start) ->
    if start
      @runButton.removeClass('btn-success').addClass('btn-danger').
        data('running', true).html('<i class="fa fa-spinner fa-lg fa-spin"></i>')
      @consoleSpinnerElement.show()
    else
      @runButton.removeClass('btn-danger').addClass('btn-success').
        data('running', false).html('<i class="fa fa-play"></i>')
      @consoleSpinnerElement.hide()

  isRunning : () ->
    $('#run').data('running')

  _runCode : () =>
    if @isRunning()
      @console.terminate()
      @_cleanup()
    else
      Sk.reset()
      @_setRunButtonState(true)
      @_clearErrors()
      @console.clear()
      code = @preamble + @codeArea.getValue()
      starter = () -> Sk.importMainWithBody("<stdin>", false, code)
      success = () =>
        @console.success()
        @_cleanup()
      Sk.runInBrowser(starter, success, @_handleException)

  _cleanup : () ->
    Sk.cancelInBrowser()
    Sk.reset()
    @_setRunButtonState(false)

  _clearErrors : () ->
    @lastErrorWidget?.clear()

  _handleError: (error) ->
    # Adjust the line numbers to make up for the preamble.
    error.start.line -= @preambleLines if error.start
    error.end.line -= @preambleLines if error.end

    # Print the error at the bottom of the console.
    @console.error(error)

    # Add a widget to the code window showing the error.
    @_doNotTriggerChange () =>
      {message, type} = error

      if error.start
        error.end ||= error.start
        if error.start.line is error.end.line and error.start.ch is error.end.ch
          error.end.ch++

        start =
          line : error.start.line - 1
          ch : error.start.ch

        end =
          line : error.end.line - 1
          ch : error.end.ch

        widget = $('<div class="error-widget"></div>')
        widget.text("Error: #{error.message}")
        @lastErrorWidget = @codeArea.addLineWidget(start.line, widget[0])

        # Move the cursor to the error line in the code editor and give it
        # the focus.
        @codeArea.setCursor(start.line, start.ch)
        @codeArea.focus()

  _doNotTriggerChange: (func) ->
    @ignoreChange = true
    func()
    @ignoreChange = false

  _handleException: (e) =>
    if e.tp$name
      errorInfo =
        type: e.tp$name,
        message: e.args.v[0].v

      if e.args.v.length > 3
        if typeof(e.args.v[3]) is 'number'
          errorInfo.start =
            line : e.args.v[3]
            ch : e.args.v[4]
        else
          errorInfo.start =
            line : e.args.v[3][0][0]
            ch : e.args.v[3][0][1]
          errorInfo.end =
            line : e.args.v[3][1][0]
            ch : e.args.v[3][1][1]
      else
        errorInfo.start =
          line : Sk.currLineNo
          ch : Sk.currColNo
    else
      errorInfo =
        type: 'Internal error (' + e.name + ')',
        message: e.message

    @_handleError(errorInfo)
    @_cleanup()

  _initializeSkulpt : () ->
    Sk.configure
      output : @console.output
      inputfun  : (prompt) =>
        Sk.future (continueWith) =>
          @console.promptForInput(prompt, continueWith)
      read   : @_skRead
      transformUrl : CodeController.transformUrl

    # Configure the media comp module's foreign function interface.
    window.mediaffi =
      customizeMediaURL : @_mcCustomizeMediaURL
      writePictureTo : @_mcWritePictureTo

  _skRead: (file) ->
    if not Sk.builtinFiles or not Sk.builtinFiles['files'][file]
      throw("File not found: '#{file}'")
    else Sk.builtinFiles['files'][file]

  @transformUrl: (url) ->
    # TODO check for the case where the url is not in the form http://host/path
    # and is simple the path as then it will not result in a 404 if it's supposed to
    encodedUrl = encodeURIComponent(url)
    clientHost = "#{window.location.protocol}//#{window.location.host}"
    {protocol, host} = window.location

    # If the URL is to the same host, just let it go through the same;
    # otherwise, wrap it in a proxy request
    if url.indexOf(clientHost) is 0 then url
    else "#{protocol}//#{host}/proxy?url=#{encodedUrl}"

  _mcWritePictureTo: (dataURL, path, continueWith) ->
    window.pythy.uploadFileFromDataURL(path, dataURL).done (e, data) ->
      continueWith(e)

  _mcCustomizeMediaURL: (url) =>
    {protocol, host} = window.location
    if /^https?:\/\//.test(url) then url
    # If it doesn't have a protocol, then treat it as if it's a filename of
    # something in the media library.
    else "#{protocol}//#{host}/m/u/#{@mediaKey}/#{url}"

class InteractiveConsole
  constructor : (opts) ->
    {@codeController,
     @console_content,
     @resizeBar,
     @consoleWrapper,
     onInput} = opts

    @visible = false

    @_registerEventHandlers()
    
    @inputField = $('<input type="text" class="input-xlarge" placeholder=" Type something..."/>')

    @_createNewLine()

    $('#console-spinner').hide()
    
    $(window).resize () =>
      $("#code-area").css({bottom: @consoleWrapper.height() + @resizeBar.height()})
    
  _registerEventHandlers : () ->
    @resizeBar.mousedown(@initDrag)
    @codeController.workspace.mouseup(@stopDrag)

  drag: (e) =>
    @consoleWrapper.height(@consoleInitDragHeight + @initDragY - e.pageY)
    @resizeBar.css({bottom: @consoleWrapper.height()})
    @codearea.css({bottom: @consoleWrapper.height() + @resizeBar.height()})
    
  initDrag: (e) =>
    @codeController.workspace.disableSelection()
    @consoleInitDragHeight = @consoleWrapper.height()
    @codearea = $("#code-area")
    @codeareaInitDragHeight = @codearea.height()
    @initDragY = e.pageY
    @codeController.workspace.bind("mousemove", @drag)
      
  stopDrag: (e) =>
    @codeController.workspace.unbind("mousemove")
    @codeController.workspace.enableSelection()

  clear: () ->
    @console_content.empty()
    @_createNewLine()

  output: (text) =>
    lines = text.split('\n')

    firstLine = lines.shift()
    @_addToCurrentLine(firstLine)

    for line in lines
      @_createNewLine()
      @_addToCurrentLine(line)

  error : (error) ->
    @_createNewLine('text-error')

    if error.start then @_addToCurrentLine """
      Your program ended prematurely because the following error
      occurred on line #{error.start.line}: #{error.message}
      """
    else @_addToCurrentLine """
      Your program ended prematurely because the following error
      occurred: #{error.message}
      """
  success : () ->
    @_createNewLine('text-success')
    @_addToCurrentLine "Your program finished successfully."
    
  terminate : () ->
    @inputField.remove()
    @_createNewLine('text-warning')
    @_addToCurrentLine("You manually ended your program.")

  promptForInput : (prompt, callback) ->
    @_addToCurrentLine(prompt)
    @inputField.val('')
    @currentLine.append(@inputField)
    @inputField.focus()

    @inputField.unbind('change').change () =>
      text = @inputField.val()
      @inputField.remove()
      @_addToCurrentLine(text, 'text-info')
      @_createNewLine()
      callback(text)

  _createNewLine: (classes) ->
    @currentLine = $('<div class="line"></div>')
    @currentLine.addClass classes if classes
    @console_content.append(@currentLine)

    $console = $('#console')
    $console.scrollTop($console[0].scrollHeight)

  _addToCurrentLine: (text, classes) ->
    if classes
      newSpan = $("<span class=\"#{classes}\"></span>").text(text)
      @currentLine.append(newSpan)
    else
      @currentLine.append($('<div/>').text(text).html())


# Export
window.CodeController = CodeController
window.InteractiveConsole = InteractiveConsole

$ () ->
  window.codeController = new CodeController
    $codearea       : $('#codearea')
    consoleWrapper  : $('#console')
    workspace       : $('#workspace')
    resizeBar       : $("#console-resize-bar")
    console_content : $("#console-content")

  overlay = $('#code-loading-overlay')
  overlay.css('line-height', "#{overlay.height()}px")

  adjustCodeTop = () ->
    codeTop = $('#flashbar').height() + 35
    actionTop = codeTop + 45
    $('#code-area').css('top', "#{codeTop}px")
    $('#save-bar').css('top', "#{codeTop}px")
    $('#action-bar').css('top', "#{actionTop}px")

  $('#flashbar .flash').on('hidden', adjustCodeTop)
  adjustCodeTop()
