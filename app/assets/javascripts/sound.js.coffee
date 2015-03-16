class pythy.Sound
  @SAMPLE_RATE : 22050

  # NOTE: The maximum number of audio contexts is 6 and it looks like everytime a program is 
  # run it executes this file again, so, we need this check to protect against repeated
  # context creation.
  initializeContext: () ->
    if window.__$audioContext$__ then return

    window.AudioContext = window.AudioContext || window.webkitAudioContext
    window.__$audioContext$__ = new window.AudioContext()

  constructor: () ->
    @initializeContext()

    @buffer = null
    @channels = []
    @playbacks = []

    onSuccess = arguments[0]
    onError = arguments[1]
    arg0 = arguments[2]
    arg1 = arguments[3]
    type = typeof(arg0)

    #TODO more validation on args
    if(type is 'string')
      @url = window.mediaffi.customizeMediaURL(arg0)
      @load(onSuccess, onError)
    else if(type is 'number')
      # NOTE: Pythy supports a maximum of 2 sound channels, so any new empty
      # sound will have 2 channels by default
      @buffer = __$audioContext$__.createBuffer(2, arg0, arg1 || SAMPLE_RATE)
      @channels[i] = @buffer.getChannelData(i) for i in [0..@buffer.numberOfChannels - 1]
      onSuccess(this)
     
    #else
      #TODO: throw exception
   
  load : (onSuccess, onError) ->
    request = new XMLHttpRequest()

    request.onload = () =>
      __$audioContext$__.decodeAudioData request.response, (decodedData) =>
        @buffer = decodedData
        @channels[i] = @buffer.getChannelData(i) for i in [0..@buffer.numberOfChannels - 1]
        onSuccess(this)
   
    #TODO: Fix this [because server doesn't respond with 404 if not prefixed with http:]
    # Also use jquery ajax instead of xmlhttprequest for now. (it has better error handling)
    request.onerror = request.timeout = onError

    request.open('GET', CodeController.transformUrl(@url), true)
    request.responseType = 'arraybuffer'
    request.send()

  _cloneBuffer : () ->
    buffer = __$audioContext$__.createBuffer(@buffer.numberOfChannels, @buffer.length, @buffer.sampleRate)
    for i in [0..@buffer.numberOfChannels - 1]
      toChannel = buffer.getChannelData(i)
      fromChannel = @buffer.getChannelData(i)
      toChannel[j] = fromChannel[j] for j in [0..fromChannel.length - 1]
    return buffer

  play : (callback) ->
    source = @_getPlayback(if callback then false else true)
    source.onended = callback
    source.start(0)

  playBefore: (time) ->
    @getPlayback().start(0, 0, time)

  playAfter: (time) ->
    @getPlayback().start(0, time)

  playSelection: (from, to) ->
    @getPlayback().start(0, 0, from, to - from)

  stop: () ->
    playback.stop() for playback in @playbacks
    @playbacks = []

  getDuration : () -> return @buffer.duration

  getLength : () -> return @buffer.length

  setLeftSample : (index, value) -> @channels[0][index] = value

  setRightSample : (index, value) -> @channels[1][index] = value

  getLeftSample : (index) -> return @channels[0][index]

  getRightSample : (index) -> return @channels[1][index]

  getSample: (channelNum, index) -> return @channels[channelNum][index]

  getSamplingRate: () -> return @buffer.sampleRate

  _getPlayback: (clone) ->
    source = window.__$audioContext$__.createBufferSource()
    @playbacks.push(source)
    #Protects it from being affected by subsequent setSampleValueAt modifications
    source.buffer = if clone then @_cloneBuffer() else @buffer
    source.connect(context.destination)
    return source
