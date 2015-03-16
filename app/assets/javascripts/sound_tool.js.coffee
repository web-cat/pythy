class Line
  constructor: (canvasId, @width, @sound, @nthSample, @channelNum) ->
    @canvas = document.getElementById(canvasId)

    if(!@canvas) then throw new Error('Could not find canvas')
    
    @ctx = @canvas.getContext('2d')
    @canvas.width = @width
    @height = @canvas.height
    @x = 0

    @sampleNumberEl = document.getElementById('sample-number')
    @valueEl = document.getElementById('value')

  color: 'rgb(0, 255, 0)'

  setX: (x)  -> @x = x

  getX: () -> return @x

  draw: (x) ->
    @clear()
    @setX(x)
    @ctx.beginPath()
    @ctx.strokeStyle = @color
    @ctx.moveTo(x, 0)
    @ctx.lineTo(x, @height)
    @ctx.stroke()
    @ctx.closePath()

  update: (x) ->
    if(x < 0 || x >= @width) then return

    sampleNumber = x * @nthSample

    @draw(x)

    @sampleNumberEl.value = sampleNumber
    @valueEl.innerText = @sound.getSample(@channelNum, sampleNumber)

  getSampleNumber: () -> return @x * @nthSample

  clear: () -> @ctx.clearRect(0, 0, @width, @height)

class Waveform
  constructor: (canvasId, @width, @sound, @nthSample, @channelNum)  ->
    @canvas = document.getElementById(canvasId)

    if not @canvas then throw new Error('Could not find canvas')
    
    @ctx = @canvas.getContext('2d')
    @canvas.width = @width
    @height = @canvas.height
    @animationStepSize = 5000

    @_x = 0
    @_i = 0

  waveformColor: 'rgb(255, 255, 255)'

  backgroundColor: 'rgb(0, 0, 0)'

  axisColor: 'rgb(0, 255, 0)'

  drawAxis: () ->
    @ctx.beginPath()
    @ctx.strokeStyle = @axisColor
    @ctx.moveTo(0, @height/2)
    @ctx.lineTo(@width, @height/2)
    @ctx.stroke()
    @ctx.closePath()

  drawBackground: () ->
    @ctx.fillStyle = @backgroundColor
    @ctx.fillRect(0, 0, @width, @height)

  animate: () ->
    step = 0

    if(@_x < @width)
      requestAnimationFrame(@animate.bind(this))

      while(@_x < @width && step < @animationStepSize)
        @ctx.lineTo(@_x, (1 - @sound.getSample(@channelNum, @_i)) * @height / 2)
        step++; @_x++; @_i += @nthSample
      @ctx.stroke()

     else
      @ctx.closePath()

  draw: () ->
    @clear()
    @drawBackground()
    @drawAxis()

    @ctx.beginPath()
    @ctx.strokeStyle = @waveformColor
    @ctx.moveTo(0, (@sound.getSample(@channelNum, 0) + 1) * @height/ 2)

    @_x = 0
    @_i = 0

    @animate()

  clear: () -> @ctx.clearRect(0, 0, @width, @height)

class Selection
  constructor: (canvasId, @width, @nthSample) ->
    @canvas = document.getElementById(canvasId)

    if(!@canvas) then throw new Error('Could not find canvas')
    
    @ctx = @canvas.getContext('2d')
    @canvas.width = @width
    @height = @canvas.height
    @color = 'rgba(100, 100, 100, 0.4)'
    @start = @end = 0
    # TODO Add elements that indicate the start and end sample of the selection

  getStart: () -> return @start * @nthSample

  getEnd: () -> return @end * @nthSample

  clear: () ->
    @start = 0
    @end = 0
    @ctx.clearRect(0, 0, @width, @height)

  draw: (start, end)  ->
    @clear()
    @start = start
    @end = end
    @ctx.fillStyle = @color
    @ctx.fillRect(start, 0, end - start, @height)

class SoundTool
  constructor: (@channelNum) ->
    @playBtn           = document.getElementById('play')
    @playAfterBtn      = document.getElementById('play-after')
    @playBeforeBtn     = document.getElementById('play-before')
    @playSelectionBtn  = document.getElementById('play-selection')
    @clearSelectionBtn = document.getElementById('clear-selection')
    @nextPixel         = document.getElementById('next-pixel')
    @previousPixel     = document.getElementById('previous-pixel')
    @lineToStart       = document.getElementById('line-to-start')
    @lineToEnd         = document.getElementById('line-to-end')
    @zoomValue         = document.getElementById('zoom')
    @stopBtn           = document.getElementById('stop')
    @container         = document.getElementById('container')
    @sampleNumberEl    = document.getElementById('sample-number')
    @zoomIn            = document.getElementById('zoom-in')
    @zoomOut           = document.getElementById('zoom-out')
    @widget            = $('#mediacomp-soundtool')
    @widget.modal({ backdrop: false, keyboard: true, show: false })
    @widget.draggable({ handle: '.modal-header' })

    canvases = document.getElementsByTagName('canvas')
    @topCanvas = canvases[canvases.length - 1]

    @eventHandlers = [
      {
        element: @playSelectionBtn,
        evt: 'click',
        handler: () => @sound.playSelection(@getStartSelection(), @getEndSelection())
      },
      {
        element: @clearSelectionBtn,
        evt: 'click',
        handler: () => @clearSelection()
      },
      {
        element: @nextPixel,
        evt: 'click',
        handler: () => @moveLine(1)
      },
      {
        element: @previousPixel,
        evt: 'click',
        handler: () => @moveLine(-1)
      },
      {
        element: @lineToStart,
        evt: 'click',
        handler: () => @moveLineToStart()
      },
      {
        element: @lineToEnd,
        evt: 'click',
        handler: () => @moveLineToEnd()
      },
      {
        element: @playBtn,
        evt: 'click',
        handler: () => @sound.play()
      },
      {
        element: @playAfterBtn,
        evt: 'click',
        handler: () => @sound.playAfter(@getSelectionTime())
      },
      {
        element: @playBeforeBtn,
        evt: 'click',
        handler: () => @sound.playBefore(@getSelectionTime())
      },
      {
        element: @stopBtn,
        evt: 'click',
        handler: () => @sound.stop()
      },
      {
        element: @zoomValue,
        evt: 'keyup',
        handler: (evt) => if evt.keyCode is 13 then @start(@url, parseInt(@zoomValue.value))
      },
      {
        element: @zoomIn,
        evt: 'click',
        handler: () => @start(@url, 1)
      },
      {
        element: @zoomOut,
        evt: 'click',
        handler: () => @start(@url)
      },
      {
        element: @sampleNumberEl,
        evt: 'keyup',
        handler: (evt) =>
          if evt.keyCode isnt 13 then return
          @line.update(parseInt(@sampleNumberEl.value / parseInt(@zoomValue.value)))
          @scrollToPosition()
      },
      {
        element: @topCanvas,
        evt: 'mousedown',
        handler: (evt)  =>
          @_startClick = evt.timeStamp
          @_selectionStart = @getActualX(evt)
      },
      {
        element: @topCanvas,
        evt: 'mouseup',
        handler: (evt) =>
          if(evt.timeStamp - @_startClick <= 200)
            @line.update(@getActualX(evt))
           else
            @_selectionEnd = @getActualX(evt)
            @selection.draw(@_selectionStart, @_selectionEnd)
      }
    ]


  getActualX: (evt) ->
    return (evt.x or evt.clientX) + @container.scrollLeft - @container.offsetLeft - @widget[0].offsetLeft

  _onLoad: (nthSample) ->
    @widget.modal('show')
    @detachEventHandlers()

    if not nthSample then nthSample = parseInt(@sound.getLength() / @container.clientWidth)

    @width = @sound.getLength() / nthSample
    @zoomValue.value = nthSample

    @waveform = new Waveform('waveform', @width, @sound, nthSample, @channelNum)
    @waveform.draw()

    @line = new Line('line-overlay', @width, @sound, nthSample, @channelNum)
    @line.update(0)

    @selection = new Selection('selection', @width, nthSample)

    @attachEventHandlers()

  start: (@url, nthSample) ->
    @sound = new pythy.Sound((() => @_onLoad(nthSample)), null, @url)

  detachEventHandlers: () ->
    evtHldr.element.removeEventListener(evtHldr.evt, evtHldr.handler) for evtHldr in @eventHandlers

  attachEventHandlers: () ->
    evtHldr.element.addEventListener(evtHldr.evt, evtHldr.handler) for evtHldr in @eventHandlers

  scrollToPosition: () ->
    @container.scrollLeft = @line.getX() - @container.clientWidth / 2

  moveLine: (direction)  ->
    @line.update(@line.getX() + direction)

  moveLineToStart: () ->
    @line.update(0)
    @scrollToPosition()

  moveLineToEnd: () ->
    @line.update(@width - 1)
    @scrollToPosition()

  getSelectionTime: () ->
    return @line.getSampleNumber() * @sound.getDuration() / @sound.getLength()

  getStartSelection: () ->
    return @selection.getStart() * @sound.getDuration() / @sound.getLength()

  getEndSelection: () ->
    return @selection.getEnd() * @sound.getDuration() / @sound.getLength()

  clearSelection: () -> @selection.clear()

  hide: () -> @widget.modal('hide')

window.addEventListener 'load', () -> window.pythy.soundTool = new SoundTool(0)
