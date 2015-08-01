class ColorPicker
  constructor: (options) ->
    @canvas = document.getElementById(options.canvasId)
    @canvas.width = @width
    @canvas.height = @height
    @ctx = @canvas.getContext('2d')

    @redElt = $('#' + options.redId)
    @greenElt = $('#' + options.greenId)
    @blueElt = $('#' + options.blueId)
    @swatchElt = $('#' + options.swatchId)
    @colorpicker = $('#' + options.widgetId)
    @okElt = $('#' + options.okId)
    @cancelElt = $('#' + options.cancelId)
    @closeElt = $('.' + options.closeClass, @colorpicker)
    @colorFields = $('.' + options.colorClass)

    @fillColors()
    @initializeSidebar()
    @attachEventHandlers()

  width: 360

  height: 360

  initializeSidebar: () ->
    @redElt.val(0)
    @greenElt.val(0)
    @blueElt.val(0)

  hue2rgb: (p, q, t) ->
    if (t < 0) then t += 1
    else if (t > 1) then t -= 1

    if (t < 1 / 6)  then p = p + (q - p) * 6 * t
    else if (t < 1 / 2)  then p = q
    else if (t < 2 / 3)  then p = p + (q - p) * (2 / 3 - t) * 6

    return p

  hsl2rgb : (h, s, l) ->
    if (s is 0) then r = g = b = l # achromatic
    else
      q = if l < 0.5 then l * (1 + s) else l + s - l * s
      p = 2 * l - q
      hp = h / 360
      r = @hue2rgb(p, q, hp + 1 / 3)
      g = @hue2rgb(p, q, hp)
      b = @hue2rgb(p, q, hp - 1 / 3)

    return [r * 255, g * 255, b * 255]

  fillColors:  () ->
    imageData = @ctx.getImageData(0, 0, @width, @height)

    for y in [0..@height]
      for x in [0..@width]
        h = x
        s = 1
        l = y / @height
        rgb = @hsl2rgb(h, s, l)
        idx = y * @width * 4 + x * 4

        imageData.data[idx]     = rgb[0]
        imageData.data[idx + 1] = rgb[1]
        imageData.data[idx + 2] = rgb[2]
        imageData.data[idx + 3] = 255
      
    
    @ctx.putImageData(imageData, 0, 0)

  updateColor:  (r, g, b) ->
    @redElt.val(r)
    @greenElt.val(g)
    @blueElt.val(b)
    @swatchElt.css('background-color', 'rgb(' + r + ',' + g + ',' + b + ')')

  handleDrag:  (e) ->
    hue = e.offsetX
    lit = e.offsetY / $(@canvas).height()
    rgb = @hsl2rgb(hue, 1, lit)

    r = Math.floor(rgb[0])
    g = Math.floor(rgb[1])
    b = Math.floor(rgb[2])

    @updateColor(r, g, b)

  attachEventHandlers:  () ->
    $(@canvas).on 'mousedown', (e) =>
      $(@canvas).on 'mousemove',  (e) => @handleDrag(e)
      @handleDrag(e)

    $(@canvas).on 'mouseup', (e) => $(@canvas).off('mousemove')

    @immediateChange @colorFields, () =>
      r = parseInt(@redElt.val(), 10)
      g = parseInt(@greenElt.val(), 10)
      b = parseInt(@blueElt.val(), 10)

      @updateColor(r, g, b)

  show : (callback) ->
    @colorpicker.modal('show')

    @okElt.on 'click', (e) =>
      r = parseInt(@redElt.val(), 10)
      g = parseInt(@greenElt.val(), 10)
      b = parseInt(@blueElt.val(), 10)

      @okElt.off('click')
      @cancelElt.off('click')
      @closeElt.off('click')
      callback(r, g, b)

    @cancelElt.on 'click', (e) =>
      @okElt.off('click')
      @cancelElt.off('click')
      @closeElt.off('click')
      callback(0, 0, 0) #Default is black

    @closeElt.on 'click', (e) =>
      @okElt.off('click')
      @cancelElt.off('click')
      @closeElt.off('click')
      callback(0, 0, 0) #Default is black
  
  # Binds a callback to a form field when any immediate change occurs, rather
  # than when the field goes out of focus.
  # Uses dirty checking
  #
  # @param selector
  # @param callback
  immediateChange : (selector, callback) ->
    selector.each () ->
      $this = $(this)
      $this.data('oldVal', $this)
      $this.bind 'propertychange keyup input cut paste', (e) ->
        val = $this.val()
        if ($this.data('oldVal') isnt val)
          $this.data('oldVal', val)
          callback(val)

addEventListener 'load', () ->
  window.pythy.colorPicker = new ColorPicker({
    canvasId  : 'mediacomp-colorpicker-canvas'
    redId     : 'mediacomp-color-red'
    greenId   : 'mediacomp-color-green'
    blueId    : 'mediacomp-color-blue'
    swatchId  : 'mediacomp-color-swatch'
    widgetId  : 'mediacomp-colorpicker'
    okId      : 'mediacomp-colorpicker-ok'
    cancelId  : 'mediacomp-colorpicker-cancel'
    colorClass: 'mediacomp-color-field'
    closeClass: 'close'
  })
