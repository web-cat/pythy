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
      @buffer = __$audioContext$__.createBuffer(2, arg0, arg1 || pythy.Sound.SAMPLE_RATE)
      @channels[i] = @buffer.getChannelData(i) for i in [0..@buffer.numberOfChannels - 1]
      onSuccess and onSuccess(this)
     
    #else
      #TODO: throw exception
   
  load : (onSuccess, onError) ->
    request = new XMLHttpRequest()

    request.onload = () =>
      __$audioContext$__.decodeAudioData request.response, (decodedData) =>
        @buffer = decodedData
        @channels[i] = @buffer.getChannelData(i) for i in [0..@buffer.numberOfChannels - 1]
        onSuccess && onSuccess(this)
   
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

  getUrl: () ->
    return @url

  play : (callback) ->
    source = @_getPlayback(if callback then false else true)
    source.onended = callback
    source.start(0)

  playBefore: (time) ->
    @_getPlayback().start(0, 0, time)

  playAfter: (time) ->
    @_getPlayback().start(0, time)

  playSelection: (from, to) ->
    @_getPlayback().start(0, from, to - from)

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
    source.connect(window.__$audioContext$__.destination)
    return source

  _getExtension: (filename) ->
    return filename.split('.').pop()

  save: (filename) ->
    type = "audio/#{@_getExtension(filename)}"

    switch @buffer.numberOfChannels
      when 1 then samples = @buffer.getChannelData(0)
      when 2 then samples = @_interleave(@buffer.getChannelData(0), @buffer.getChannelData(1))
      else throw new Error('Pythy does not support more than 2 channels')

    blob = new Blob([@_encodeWAV(samples)], { type: type })
    pythy.uploadFileFromBlob(filename, blob)

  # The following methods for encoding to Wav are based on https://github.com/mattdiamond/Recorderjs

  _interleave: (inputL, inputR) ->
    length = inputL.length + inputR.length
    result = new Float32Array(length)

    index = 0; inputIndex = 0

    while index < length
      result[index++] = inputL[inputIndex]
      result[index++] = inputR[inputIndex]
      inputIndex++

    return result

  _floatTo16BitPCM: (output, offset, input) ->
    for value in input
      s = Math.max(-1, Math.min(1, value))
      output.setInt16(offset, (if s < 0 then s * 0x8000 else s * 0x7FFF), true)
      offset += 2

  _writeString: (view, offset, string) ->
    view.setUint8(offset + i, string.charCodeAt(i)) for i in [0..(string.length - 1)]

  _encodeWAV: (samples) ->
    view = new DataView(new ArrayBuffer(44 + samples.length * 2))

    # RIFF identifier
    @_writeString(view, 0, 'RIFF')
    # RIFF chunk length
    view.setUint32(4, 36 + samples.length * 2, true)
    # RIFF type
    @_writeString(view, 8, 'WAVE')
    # format chunk identifier
    @_writeString(view, 12, 'fmt ')
    # format chunk length
    view.setUint32(16, 16, true)
    # sample format (raw)
    view.setUint16(20, 1, true)
    # channel count
    view.setUint16(22, @buffer.numberOfChannels, true)
    # sample rate
    view.setUint32(24, @buffer.sampleRate, true)
    # byte rate (sample rate * block align)
    view.setUint32(28, @buffer.sampleRate * 4, true)
    # block align (channel count * bytes per sample)
    view.setUint16(32, @buffer.numberOfChannels * 2, true)
    # bits per sample
    view.setUint16(34, 16, true)
    # data chunk identifier
    @_writeString(view, 36, 'data')
    # data chunk length
    view.setUint32(40, samples.length * 2, true)

    @_floatTo16BitPCM(view, 44, samples)

    return view
