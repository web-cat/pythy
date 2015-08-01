# Note: The browser resamples the sound with the sampling rate of the audio context (usually 44100).
# So, the sampling rate and number of samples reported through this API
# may be different from the original. See - https://github.com/WebAudio/web-audio-api/issues/30
class pythy.Sound
  @SAMPLE_RATE : 44100

  @mapFloatTo16BitInt: (sampleValue) ->
    return parseInt(sampleValue * 32768)

  @map16BitIntToFloat: (sampleValue) ->
    return sampleValue / 32768

  # NOTE: The maximum number of audio contexts is 6 and it looks like everytime a program is 
  # run it executes this file again, so, we need this check to protect against repeated
  # context creation.
  _initializeContext: () ->
    if window.__$audioContext$__ then return

    window.AudioContext = window.AudioContext || window.webkitAudioContext
    window.__$audioContext$__ = new window.AudioContext()

  constructor: () ->
    @_initializeContext()

    @buffer = null
    @channels = []
    @playbacks = []

    onSuccess = arguments[0]
    onError = arguments[1]
    arg0 = arguments[2]
    arg1 = arguments[3]
    type = typeof(arg0)

    if(type is 'string' && arg0.trim().length)
      @url = window.mediaffi.customizeMediaURL(arg0)
      @load(onSuccess, onError)
    else if(type is 'number')
      # NOTE: Pythy supports a maximum of 2 sound channels, so any new empty
      # sound will have 2 channels by default
      arg1 = arg1 || pythy.Sound.SAMPLE_RATE
      if(arg0 < 0) then return onError('Number of samples can not be negative')
      if(arg1 < 0) then return onError('Sampling rate can not be negative')
      if(arg0 / arg1 > 600) then return onError('Duration can not be greater than 600 seconds')
      @buffer = __$audioContext$__.createBuffer(2, arg0, arg1)
      @channels[i] = @buffer.getChannelData(i) for i in [0..@buffer.numberOfChannels - 1]
      onSuccess and onSuccess(this)
    else if(arg0 instanceof pythy.Sound)
      @buffer = __$audioContext$__.createBuffer(arg0.buffer.numberOfChannels, arg0.getLength(), arg0.getSamplingRate())
      @channels[i] = arg0.buffer.getChannelData(i) for i in [0..arg0.buffer.numberOfChannels - 1]
      onSuccess and onSuccess(this)
    else
      throw new Error('Must provide either a url or number of samples with the sample rate optionally')
   
  load : (onSuccess, onError) ->
    request = new XMLHttpRequest()

    request.onload = () =>
      if request.status isnt 200
        onError && onError(request.statusText)
      else if not request.response instanceof ArrayBuffer
        onError && onError('File not found or is not of the correct type')
      else
        __$audioContext$__.decodeAudioData request.response,
        (decodedData) =>
          @buffer = decodedData
          @channels[i] = @buffer.getChannelData(i) for i in [0..@buffer.numberOfChannels - 1]
          onSuccess && onSuccess(this)
        , (error) ->
          onError && onError('File not found or is not of the correct type')
   
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

  _getMimeType: (filename) ->
    switch(@_getExtension(filename))
      when 'mp3' then 'audio/mpeg'
      when 'wav' then 'audio/wav'

  _getExtension: (filename) ->
    return filename.split('.').pop()

  _replaceExtension: (filename, ext) ->
    return filename.split('.')[0] + ext

  save: (filename, continueWith) ->
    type = @_getMimeType(filename)

    switch @buffer.numberOfChannels
      when 1 then samples = @buffer.getChannelData(0)
      when 2 then samples = @_interleave(@buffer.getChannelData(0), @buffer.getChannelData(1))
      else throw new Error('Pythy does not support more than 2 channels')

    blob = new Blob([@_encodeWAV(samples)], { type: type })
    # This tells the server that it's actually a wav binary that needs to be converted into an mp3 file
    if type is 'audio/mpeg' then filename = @_replaceExtension(filename, '.wavmp3')
    pythy.uploadFileFromBlob(filename, blob).done (e, data) ->
      continueWith(e)

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
