jQuery.fn.farbtastic = (callback) ->
  $.farbtastic this, callback
  this

jQuery.farbtastic = (container, callback) ->
  container = $(container).get(0)
  container.farbtastic or (container.farbtastic = new jQuery._farbtastic(container, callback))

jQuery._farbtastic = (container, callback) ->
  fb = this
  $(container).html "<div class=\"farbtastic\"><div class=\"color\"></div><div class=\"wheel\"></div><div class=\"overlay\"></div><div class=\"h-marker marker\"></div><div class=\"sl-marker marker\"></div></div>"
  e = $(".farbtastic", container)
  fb.wheel = $(".wheel", container).get(0)
  fb.radius = 84
  fb.square = 80
  fb.width = 194
  #
  #
  #
  if navigator.appVersion.match(/MSIE [0-6]\./)
    $("*", e).each ->
      unless @currentStyle.backgroundImage is "none"
        image = @currentStyle.backgroundImage
        image = @currentStyle.backgroundImage.substring(5, image.length - 2)
        $(this).css
          backgroundImage: "none"
          filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='" + image + "')"
  #
  #
  #
  fb.linkTo = (callback) ->
    $(fb.callback).unbind "keyup", fb.updateValue  if typeof fb.callback is "object"
    fb.color = null
    if typeof callback is "function"
      fb.callback = callback
    else if typeof callback is "object" or typeof callback is "string"
      fb.callback = $(callback)
      fb.callback.bind "keyup", fb.updateValue
      fb.setColor fb.callback.get(0).value  if fb.callback.get(0).value
    #
    #
    #
    #
    $fb_callback = $(fb.callback)
    
    #
    #
    #
    this

  fb.updateValue = (event) ->
    if not @value.match /^#/
      @value = '#' + @value
      fb.setColor @value  if @value and @value isnt fb.color

  fb.setColor = (color) ->
    unpack = fb.unpack(color)
    if fb.color isnt color and unpack
      fb.color = color
      fb.rgb = unpack
      fb.hsl = fb.RGBToHSL(fb.rgb)
      fb.updateDisplay()
    this

  fb.setHSL = (hsl) ->
    fb.hsl = hsl
    fb.rgb = fb.HSLToRGB(hsl)
    fb.color = fb.pack(fb.rgb)
    fb.updateDisplay()
    this

  fb.widgetCoords = (event) ->
    x = undefined
    y = undefined
    el = event.target or event.srcElement
    reference = fb.wheel
    unless typeof event.offsetX is "undefined"
      pos =
        x: event.offsetX
        y: event.offsetY

      e = el
      while e
        e.mouseX = pos.x
        e.mouseY = pos.y
        pos.x += e.offsetLeft
        pos.y += e.offsetTop
        e = e.offsetParent
      e = reference
      offset =
        x: 0
        y: 0

      while e
        unless typeof e.mouseX is "undefined"
          x = e.mouseX - offset.x
          y = e.mouseY - offset.y
          break
        offset.x += e.offsetLeft
        offset.y += e.offsetTop
        e = e.offsetParent
      e = el
      while e
        e.mouseX = `undefined`
        e.mouseY = `undefined`
        e = e.offsetParent
    else
      pos = fb.absolutePosition(reference)
      x = (event.pageX or 0 * (event.clientX + $("html").get(0).scrollLeft)) - pos.x
      y = (event.pageY or 0 * (event.clientY + $("html").get(0).scrollTop)) - pos.y
    x: x - fb.width / 2
    y: y - fb.width / 2

  fb.mousedown = (event) ->
    unless document.dragging
      $(document).bind("mousemove", fb.mousemove).bind "mouseup", fb.mouseup
      document.dragging = true
    pos = fb.widgetCoords(event)
    #
    #
    $et = $ event.target
    if $et.hasClass('wheel') or $et.hasClass('h-marker')
      if Math.max(Math.abs(pos.x), Math.abs(pos.y)) * 2 > 100
        fb.target = 'h'
      else
        fb.target = 'i'
    else
      fb.target = 'sl'
    #
    #
    fb.mousemove event
    false

  fb.mousemove = (event) ->
    pos = fb.widgetCoords(event)
    if fb.target is 'h'
      hue = Math.atan2(pos.x, -pos.y) / 6.28
      hue += 1  if hue < 0
      fb.setHSL [ hue, fb.hsl[1], fb.hsl[2] ]
    else if fb.target is 'sl'
      sat = Math.max(0, Math.min(1, -(pos.x / fb.square) + .5))
      lum = Math.max(0, Math.min(1, -((pos.y+20) / fb.square) + .5))
      fb.setHSL [ fb.hsl[0], sat, lum ]
    else
      $(fb.callback).focus().select()
    false

  fb.mouseup = ->
    $(document).unbind "mousemove", fb.mousemove
    $(document).unbind "mouseup", fb.mouseup
    document.dragging = false

  fb.updateDisplay = ->
    angle = fb.hsl[0] * 6.28
    $(".h-marker", e).css
      left: Math.round(Math.sin(angle) * fb.radius + fb.width / 2) + "px"
      top: Math.round(-Math.cos(angle) * fb.radius + fb.width / 2) + "px"

    $(".sl-marker", e).css
      left: Math.round(fb.square * (.5 - fb.hsl[1]) + fb.width / 2) + "px"
      top: Math.round(fb.square * (.5 - fb.hsl[2]) + fb.width / 2 - 20) + "px"

    $(".color", e).css "backgroundColor", fb.pack(fb.HSLToRGB([ fb.hsl[0], 1, 0.5 ]))
    if typeof fb.callback is "object"
      $(fb.callback).css
        backgroundColor: fb.color
        color: (if fb.hsl[2] > 0.5 then "#000" else "#fff")

      $(fb.callback).each ->
        @value = fb.color  if @value and @value isnt fb.color
      .change()
    else fb.callback.call fb, fb.color  if typeof fb.callback is "function"

  fb.absolutePosition = (el) ->
    r =
      x: el.offsetLeft
      y: el.offsetTop

    if el.offsetParent
      tmp = fb.absolutePosition(el.offsetParent)
      r.x += tmp.x
      r.y += tmp.y
    r

  fb.pack = (rgb) ->
    r = Math.round(rgb[0] * 255)
    g = Math.round(rgb[1] * 255)
    b = Math.round(rgb[2] * 255)
    "#" + (if r < 16 then "0" else "") + r.toString(16) + (if g < 16 then "0" else "") + g.toString(16) + (if b < 16 then "0" else "") + b.toString(16)

  fb.unpack = (color) ->
    if color.length is 7
      [ parseInt("0x" + color.substring(1, 3)) / 255, parseInt("0x" + color.substring(3, 5)) / 255, parseInt("0x" + color.substring(5, 7)) / 255 ]
    else [ parseInt("0x" + color.substring(1, 2)) / 15, parseInt("0x" + color.substring(2, 3)) / 15, parseInt("0x" + color.substring(3, 4)) / 15 ]  if color.length is 4

  fb.HSLToRGB = (hsl) ->
    m1 = undefined
    m2 = undefined
    r = undefined
    g = undefined
    b = undefined
    h = hsl[0]
    s = hsl[1]
    l = hsl[2]
    m2 = (if (l <= 0.5) then l * (s + 1) else l + s - l * s)
    m1 = l * 2 - m2
    [ @hueToRGB(m1, m2, h + 0.33333), @hueToRGB(m1, m2, h), @hueToRGB(m1, m2, h - 0.33333) ]

  fb.hueToRGB = (m1, m2, h) ->
    h = (if (h < 0) then h + 1 else (if (h > 1) then h - 1 else h))
    return m1 + (m2 - m1) * h * 6  if h * 6 < 1
    return m2  if h * 2 < 1
    return m1 + (m2 - m1) * (0.66666 - h) * 6  if h * 3 < 2
    m1

  fb.RGBToHSL = (rgb) ->
    min = undefined
    max = undefined
    delta = undefined
    h = undefined
    s = undefined
    l = undefined
    r = rgb[0]
    g = rgb[1]
    b = rgb[2]
    min = Math.min(r, Math.min(g, b))
    max = Math.max(r, Math.max(g, b))
    delta = max - min
    l = (min + max) / 2
    s = 0
    s = delta / (if l < 0.5 then (2 * l) else (2 - 2 * l))  if l > 0 and l < 1
    h = 0
    if delta > 0
      h += (g - b) / delta  if max is r and max isnt g
      h += (2 + (b - r) / delta)  if max is g and max isnt b
      h += (4 + (r - g) / delta)  if max is b and max isnt r
      h /= 6
    [ h, s, l ]

  $("*", e).mousedown fb.mousedown
  fb.setColor "#000000"
  fb.linkTo callback  if callback