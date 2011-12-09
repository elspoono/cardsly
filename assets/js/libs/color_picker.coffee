$.refresh = {}
$.refresh.Web = {}
$.refresh.Web.DefaultColorPickerSettings =
  startMode: "h"
  startHex: "ff0000"
  clientFilesPath: "/images/colorpicker/"

class $.refresh.Web.ColorPicker
  constructor: (id, settings) ->
    @id = id
    @settings = $.extend($.extend({}, $.refresh.Web.DefaultColorPickerSettings), settings or {})
    @_hueRadio = $('#' + @id + "_HueRadio")
    @_saturationRadio = $('#' + @id + "_SaturationRadio")
    @_valueRadio = $('#' + @id + "_BrightnessRadio")
    @_redRadio = $('#' + @id + "_RedRadio")
    @_greenRadio = $('#' + @id + "_GreenRadio")
    @_blueRadio = $('#' + @id + "_BlueRadio")
    @_hueRadio.value = "h"
    @_saturationRadio.value = "s"
    @_valueRadio.value = "v"
    @_redRadio.value = "r"
    @_greenRadio.value = "g"
    @_blueRadio.value = "b"
    @_hueRadio.click @_event_onRadioClicked
    @_saturationRadio.click @_event_onRadioClicked
    @_valueRadio.click @_event_onRadioClicked
    @_redRadio.click @_event_onRadioClicked
    @_greenRadio.click @_event_onRadioClicked
    @_blueRadio.click @_event_onRadioClicked
    @_preview = $('#' + @id + "_Preview")
    @_mapBase = $('#' + @id + "_ColorMap")
    @_mapBase.css
      width: 256
      height: 256
      padding: 0
      margin: 0
      border: 'solid 1px #000'
    @_mapL1 = $('<img />').css
      src: @settings.clientFilesPath + "blank.gif"
      width: 256
      height: 256
      margin: 0
    @_mapBase.append @_mapL1
    @_mapL2 = $('<img />').css
      src: @settings.clientFilesPath + "blank.gif"
      width: 256
      height: 256
      clear: 'both'
      margin: '-256px 0px 0px 0px'
    @_mapBase.append @_mapL2
    @_mapL2.fadeTo 0, .5
    @_bar = $('#' + @id + "_ColorBar").css
      width: 20
      height: 256
      padding: 0
      margin: '0px 10px'
      border: 'solid 1px #000'
    @_barL1 = $('<img />').css
      src: @settings.clientFilesPath + "blank.gif"
      width: 20
      height: 256
      margin : 0
    @_bar.append @_barL1
    @_barL2 = $('<img />').css
      src: @settings.clientFilesPath + "blank.gif"
      width: 20
      height: 256
      margin : '-256px 0px 0px 0px'
    @_bar.append @_barL2
    @_barL3 = $('<img />').css
      src: @settings.clientFilesPath + "blank.gif"
      width: 20
      height: 256
      margin: '-256px 0px 0px 0px'
      backgroundColor: '#ff0000'
    @_bar.append @_barL3
    @_barL4 = $('<img />').css
      src: @settings.clientFilesPath + "bar-brightness.png"
      width: 20
      height: 256
      margin: '-256px 0px 0px 0px'
    @_bar.append @_barL4
    @_map = new $.refresh.Web.Slider @_mapL2,
      xMaxValue: 255
      yMinValue: 255
      arrowImage: @settings.clientFilesPath + "mappoint.gif"
    @_slider = new $.refresh.Web.Slider @_barL4,
      xMinValue: 1
      xMaxValue: 1
      yMinValue: 255
      arrowImage: @settings.clientFilesPath + "rangearrows.gif"
    @_cvp = new $.refresh.Web.ColorValuePicker(@id)
    cp = this
    @_slider.onValuesChanged = ->
      cp.sliderValueChanged()

    @_map.onValuesChanged = ->
      cp.mapValueChanged()

    @_cvp.onValuesChanged = ->
      cp.textValuesChanged()

    @isLessThanIE7 = false
    version = parseFloat(navigator.appVersion.split("MSIE")[1])
    @isLessThanIE7 = true  if (version < 7) and (document.body.filters)
    @setColorMode @settings.startMode
    @_cvp._hexInput.value = @settings.startHex  if @settings.startHex
    @_cvp.setValuesFromHex()
    @positionMapAndSliderArrows()
    @updateVisuals()
    @color = null

  show: ->
    @_map.Arrow.show()
    @_slider.Arrow.show()
    @_map.setPositioningVariables()
    @_slider.setPositioningVariables()
    @positionMapAndSliderArrows()

  hide: ->
    @_map.Arrow.hide()
    @_slider.Arrow.hide()

  _onRadioClicked: (e) ->
    @setColorMode e.target.value

  _onWebSafeClicked: (e) ->
    @setColorMode @ColorMode

  textValuesChanged: ->
    @positionMapAndSliderArrows()
    @updateVisuals()

  setColorMode: (colorMode) ->
    resetImage = (cp, img) ->
      cp.setAlpha img, 100
      img.css
        backgroundColor: ''
        src: cp.settings.clientFilesPath + 'blank.gif'
        filter: ''
    @color = @_cvp.color
    resetImage this, @_mapL1
    resetImage this, @_mapL2
    resetImage this, @_barL1
    resetImage this, @_barL2
    resetImage this, @_barL3
    resetImage this, @_barL4
    @_hueRadio.checked = false
    @_saturationRadio.checked = false
    @_valueRadio.checked = false
    @_redRadio.checked = false
    @_greenRadio.checked = false
    @_blueRadio.checked = false
    switch colorMode
      when "h"
        @_hueRadio.checked = true
        @_mapL1.css
          backgroundColor: "#" + @color.hex
        @_mapL2.css
          backgroundColor: "transparent"
        @setImg @_mapL2, @settings.clientFilesPath + "map-hue.png"
        @setAlpha @_mapL2, 100
        @setImg @_barL4, @settings.clientFilesPath + "bar-hue.png"
        @_map.settings.xMaxValue = 100
        @_map.settings.yMaxValue = 100
        @_slider.settings.yMaxValue = 359
      when "s"
        @_saturationRadio.checked = true
        @setImg @_mapL1, @settings.clientFilesPath + "map-saturation.png"
        @setImg @_mapL2, @settings.clientFilesPath + "map-saturation-overlay.png"
        @setAlpha @_mapL2, 0
        @setBG @_barL3, @color.hex
        @setImg @_barL4, @settings.clientFilesPath + "bar-saturation.png"
        @_map.settings.xMaxValue = 359
        @_map.settings.yMaxValue = 100
        @_slider.settings.yMaxValue = 100
      when "v"
        @_valueRadio.checked = true
        @setBG @_mapL1, "000"
        @setImg @_mapL2, @settings.clientFilesPath + "map-brightness.png"
        @_barL3.css
          backgroundColor: "#" + @color.hex
        @setImg @_barL4, @settings.clientFilesPath + "bar-brightness.png"
        @_map.settings.xMaxValue = 359
        @_map.settings.yMaxValue = 100
        @_slider.settings.yMaxValue = 100
      when "r"
        @_redRadio.checked = true
        @setImg @_mapL2, @settings.clientFilesPath + "map-red-max.png"
        @setImg @_mapL1, @settings.clientFilesPath + "map-red-min.png"
        @setImg @_barL4, @settings.clientFilesPath + "bar-red-tl.png"
        @setImg @_barL3, @settings.clientFilesPath + "bar-red-tr.png"
        @setImg @_barL2, @settings.clientFilesPath + "bar-red-br.png"
        @setImg @_barL1, @settings.clientFilesPath + "bar-red-bl.png"
      when "g"
        @_greenRadio.checked = true
        @setImg @_mapL2, @settings.clientFilesPath + "map-green-max.png"
        @setImg @_mapL1, @settings.clientFilesPath + "map-green-min.png"
        @setImg @_barL4, @settings.clientFilesPath + "bar-green-tl.png"
        @setImg @_barL3, @settings.clientFilesPath + "bar-green-tr.png"
        @setImg @_barL2, @settings.clientFilesPath + "bar-green-br.png"
        @setImg @_barL1, @settings.clientFilesPath + "bar-green-bl.png"
      when "b"
        @_blueRadio.checked = true
        @setImg @_mapL2, @settings.clientFilesPath + "map-blue-max.png"
        @setImg @_mapL1, @settings.clientFilesPath + "map-blue-min.png"
        @setImg @_barL4, @settings.clientFilesPath + "bar-blue-tl.png"
        @setImg @_barL3, @settings.clientFilesPath + "bar-blue-tr.png"
        @setImg @_barL2, @settings.clientFilesPath + "bar-blue-br.png"
        @setImg @_barL1, @settings.clientFilesPath + "bar-blue-bl.png"
      else
        alert "invalid mode"
    switch colorMode
      when "h", "s", "v"
        @_map.settings.xMinValue = 1
        @_map.settings.yMinValue = 1
        @_slider.settings.yMinValue = 1
      when "r", "g", "b"
        @_map.settings.xMinValue = 0
        @_map.settings.yMinValue = 0
        @_slider.settings.yMinValue = 0
        @_map.settings.xMaxValue = 255
        @_map.settings.yMaxValue = 255
        @_slider.settings.yMaxValue = 255
    @ColorMode = colorMode
    @positionMapAndSliderArrows()
    @updateMapVisuals()
    @updateSliderVisuals()

  mapValueChanged: ->
    switch @ColorMode
      when "h"
        @_cvp._saturationInput.value = @_map.xValue
        @_cvp._valueInput.value = 100 - @_map.yValue
      when "s"
        @_cvp._hueInput.value = @_map.xValue
        @_cvp._valueInput.value = 100 - @_map.yValue
      when "v"
        @_cvp._hueInput.value = @_map.xValue
        @_cvp._saturationInput.value = 100 - @_map.yValue
      when "r"
        @_cvp._blueInput.value = @_map.xValue
        @_cvp._greenInput.value = 256 - @_map.yValue
      when "g"
        @_cvp._blueInput.value = @_map.xValue
        @_cvp._redInput.value = 256 - @_map.yValue
      when "b"
        @_cvp._redInput.value = @_map.xValue
        @_cvp._greenInput.value = 256 - @_map.yValue
    switch @ColorMode
      when "h", "s", "v"
        @_cvp.setValuesFromHsv()
      when "r", "g", "b"
        @_cvp.setValuesFromRgb()
    @updateVisuals()

  sliderValueChanged: ->
    switch @ColorMode
      when "h"
        @_cvp._hueInput.value = 360 - @_slider.yValue
      when "s"
        @_cvp._saturationInput.value = 100 - @_slider.yValue
      when "v"
        @_cvp._valueInput.value = 100 - @_slider.yValue
      when "r"
        @_cvp._redInput.value = 255 - @_slider.yValue
      when "g"
        @_cvp._greenInput.value = 255 - @_slider.yValue
      when "b"
        @_cvp._blueInput.value = 255 - @_slider.yValue
    switch @ColorMode
      when "h", "s", "v"
        @_cvp.setValuesFromHsv()
      when "r", "g", "b"
        @_cvp.setValuesFromRgb()
    @updateVisuals()

  positionMapAndSliderArrows: ->
    @color = @_cvp.color
    sliderValue = 0
    switch @ColorMode
      when "h"
        sliderValue = 360 - @color.h
      when "s"
        sliderValue = 100 - @color.s
      when "v"
        sliderValue = 100 - @color.v
      when "r"
        sliderValue = 255 - @color.r
      when "g"
        sliderValue = 255 - @color.g
      when "b"
        sliderValue = 255 - @color.b
    @_slider.yValue = sliderValue
    @_slider.setArrowPositionFromValues()
    mapXValue = 0
    mapYValue = 0
    switch @ColorMode
      when "h"
        mapXValue = @color.s
        mapYValue = 100 - @color.v
      when "s"
        mapXValue = @color.h
        mapYValue = 100 - @color.v
      when "v"
        mapXValue = @color.h
        mapYValue = 100 - @color.s
      when "r"
        mapXValue = @color.b
        mapYValue = 256 - @color.g
      when "g"
        mapXValue = @color.b
        mapYValue = 256 - @color.r
      when "b"
        mapXValue = @color.r
        mapYValue = 256 - @color.g
    @_map.xValue = mapXValue
    @_map.yValue = mapYValue
    @_map.setArrowPositionFromValues()

  updateVisuals: ->
    @updatePreview()
    @updateMapVisuals()
    @updateSliderVisuals()

  updatePreview: ->
    try
      @_preview.css
        backgroundColor: "#" + @_cvp.color.hex

  updateMapVisuals: ->
    @color = @_cvp.color
    switch @ColorMode
      when "h"
        color = new $.refresh.Web.Color(
          h: @color.h
          s: 100
          v: 100
        )
        @setBG @_mapL1, color.hex
      when "s"
        @setAlpha @_mapL2, 100 - @color.s
      when "v"
        @setAlpha @_mapL2, @color.v
      when "r"
        @setAlpha @_mapL2, @color.r / 256 * 100
      when "g"
        @setAlpha @_mapL2, @color.g / 256 * 100
      when "b"
        @setAlpha @_mapL2, @color.b / 256 * 100

  updateSliderVisuals: ->
    @color = @_cvp.color
    switch @ColorMode
      when "h", "s"
        saturatedColor = new $.refresh.Web.Color(
          h: @color.h
          s: 100
          v: @color.v
        )
        @setBG @_barL3, saturatedColor.hex
      when "v"
        valueColor = new $.refresh.Web.Color(
          h: @color.h
          s: @color.s
          v: 100
        )
        @setBG @_barL3, valueColor.hex
      when "r", "g", "b"
        hValue = 0
        vValue = 0
        if @ColorMode is "r"
          hValue = @_cvp._blueInput.value
          vValue = @_cvp._greenInput.value
        else if @ColorMode is "g"
          hValue = @_cvp._blueInput.value
          vValue = @_cvp._redInput.value
        else if @ColorMode is "b"
          hValue = @_cvp._redInput.value
          vValue = @_cvp._greenInput.value
        horzPer = (hValue / 256) * 100
        vertPer = (vValue / 256) * 100
        horzPerRev = ((256 - hValue) / 256) * 100
        vertPerRev = ((256 - vValue) / 256) * 100
        @setAlpha @_barL4, (if (vertPer > horzPerRev) then horzPerRev else vertPer)
        @setAlpha @_barL3, (if (vertPer > horzPer) then horzPer else vertPer)
        @setAlpha @_barL2, (if (vertPerRev > horzPer) then horzPer else vertPerRev)
        @setAlpha @_barL1, (if (vertPerRev > horzPerRev) then horzPerRev else vertPerRev)

  setBG: (el, c) ->
    try
      el.css
        backgroundColor: "#" + c

  setImg: (img, src) ->
    if src.indexOf("png") and @isLessThanIE7
      img.attr
        pngSrc: src
        src: @settings.clientFilesPath + "blank.gif"
      img.css
        filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "');"
    else
      img.attr
        src: src

  setAlpha: (obj, alpha) ->
    if @isLessThanIE7
      src = obj.pngSrc
      obj.css
        filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "') progid:DXImageTransform.Microsoft.Alpha(opacity=" + alpha + ")"  if src? and src.indexOf("map-hue") is -1
    else
      obj.fadeTo 0, alpha / 100

class $.refresh.Web.ColorValuePicker
  constructor: (id) ->
    @id = id
    @onValuesChanged = null
    @_hueInput = $('#' + @id + "_Hue")
    @_valueInput = $('#' + @id + "_Brightness")
    @_saturationInput = $('#' + @id + "_Saturation")
    @_redInput = $('#' + @id + "_Red")
    @_greenInput = $('#' + @id + "_Green")
    @_blueInput = $('#' + @id + "_Blue")
    @_hexInput = $('#' + @id + "_Hex")
    @_hueInput.keyup @_event_onHsvKeyUp
    @_valueInput.keyup @_event_onHsvKeyUp
    @_saturationInput.keyup @_event_onHsvKeyUp
    @_hueInput.blur @_event_onHsvBlur
    @_valueInput.blur @_event_onHsvBlur
    @_saturationInput.blur @_event_onHsvBlur
    @_redInput.keyup @_event_onRgbKeyUp
    @_greenInput.keyup @_event_onRgbKeyUp
    @_blueInput.keyup @_event_onRgbKeyUp
    @_redInput.blur @_event_onRgbBlur
    @_greenInput.blur @_event_onRgbBlur
    @_blueInput.blur @_event_onRgbBlur
    @_hexInput.keyup @_event_onHexKeyUp
    @color = new $.refresh.Web.Color()
    @color.setHex @_hexInput.value  unless @_hexInput.value is ""
    @_hexInput.value = @color.hex
    @_redInput.value = @color.r
    @_greenInput.value = @color.g
    @_blueInput.value = @color.b
    @_hueInput.value = @color.h
    @_saturationInput.value = @color.s
    @_valueInput.value = @color.v

  _onHsvKeyUp: (e) ->
    return  if e.target.value is ""
    @validateHsv e
    @setValuesFromHsv()
    @onValuesChanged this  if @onValuesChanged

  _onRgbKeyUp: (e) ->
    return  if e.target.value is ""
    @validateRgb e
    @setValuesFromRgb()
    @onValuesChanged this  if @onValuesChanged

  _onHexKeyUp: (e) ->
    return  if e.target.value is ""
    @validateHex e
    @setValuesFromHex()
    @onValuesChanged this  if @onValuesChanged

  _onHsvBlur: (e) ->
    @setValuesFromRgb()  if e.target.value is ""

  _onRgbBlur: (e) ->
    @setValuesFromHsv()  if e.target.value is ""

  HexBlur: (e) ->
    @setValuesFromHsv()  if e.target.value is ""

  validateRgb: (e) ->
    return e  unless @_keyNeedsValidation(e)
    @_redInput.value = @_setValueInRange(@_redInput.value, 0, 255)
    @_greenInput.value = @_setValueInRange(@_greenInput.value, 0, 255)
    @_blueInput.value = @_setValueInRange(@_blueInput.value, 0, 255)

  validateHsv: (e) ->
    return e  unless @_keyNeedsValidation(e)
    @_hueInput.value = @_setValueInRange(@_hueInput.value, 0, 359)
    @_saturationInput.value = @_setValueInRange(@_saturationInput.value, 0, 100)
    @_valueInput.value = @_setValueInRange(@_valueInput.value, 0, 100)

  validateHex: (e) ->
    return e  unless @_keyNeedsValidation(e)
    hex = new String(@_hexInput.value).toUpperCase()
    hex = hex.replace(/[^A-F0-9]/g, "0")
    hex = hex.substring(0, 6)  if hex.length > 6
    @_hexInput.value = hex

  _keyNeedsValidation: (e) ->
    return false  if e.keyCode is 9 or e.keyCode is 16 or e.keyCode is 38 or e.keyCode is 29 or e.keyCode is 40 or e.keyCode is 37 or (e.ctrlKey and (e.keyCode is "c".charCodeAt() or e.keyCode is "v".charCodeAt()))
    true

  _setValueInRange: (value, min, max) ->
    return min  if value is "" or isNaN(value)
    value = parseInt(value)
    return max  if value > max
    return min  if value < min
    value

  setValuesFromRgb: ->
    @color.setRgb @_redInput.value, @_greenInput.value, @_blueInput.value
    @_hexInput.value = @color.hex
    @_hueInput.value = @color.h
    @_saturationInput.value = @color.s
    @_valueInput.value = @color.v

  setValuesFromHsv: ->
    @color.setHsv @_hueInput.value, @_saturationInput.value, @_valueInput.value
    @_hexInput.value = @color.hex
    @_redInput.value = @color.r
    @_greenInput.value = @color.g
    @_blueInput.value = @color.b

  setValuesFromHex: ->
    @color.setHex @_hexInput.value
    @_redInput.value = @color.r
    @_greenInput.value = @color.g
    @_blueInput.value = @color.b
    @_hueInput.value = @color.h
    @_saturationInput.value = @color.s
    @_valueInput.value = @color.v


$.refresh.Web.SlidersList = []
$.refresh.Web.DefaultSliderSettings =
  xMinValue: 0
  xMaxValue: 100
  yMinValue: 0
  yMaxValue: 100
  arrowImage: "refresh_web/colorpicker/images/rangearrows.gif"

class $.refresh.Web.Slider
  _bar: null
  _arrow: null
  constructor: (passed_in, settings) ->
    @settings = $.extend($.extend({}, $.refresh.Web.DefaultSliderSettings), settings or {})
    @xValue = 0
    @yValue = 0
    @_bar = passed_in
    @_arrow = $ '<img />'
    @_arrow.attr
      border: 0
      src: @settings.arrowImage
      margin: 0
      padding: 0
      position: 'absolute'
      top: 0
      left: 0
    $(document.body).append @_arrow
    slider = this
    @setPositioningVariables()
    @_bar.mousedown @_mouseDown
    @_arrow.mousedown @_mouseDown
    @setArrowPositionFromValues()
    @onValuesChanged this  if @onValuesChanged
    $.refresh.Web.SlidersList.push this
  setPositioningVariables: ->
    @_barWidth = @_bar.width()
    @_barHeight = @_bar.height()
    pos = @_bar.offset()
    @_barTop = pos.top
    @_barLeft = pos.left
    @_barBottom = @_barTop + @_barHeight
    @_barRight = @_barLeft + @_barWidth
    @_arrow = $(@_arrow)
    @_arrowWidth = @_arrow.width()
    @_arrowHeight = @_arrow.height()
    @MinX = @_barLeft
    @MinY = @_barTop
    @MaxX = @_barRight
    @MinY = @_barBottom

  setArrowPositionFromValues: (e) ->
    @setPositioningVariables()
    arrowOffsetX = 0
    arrowOffsetY = 0
    unless @settings.xMinValue is @settings.xMaxValue
      if @xValue is @settings.xMinValue
        arrowOffsetX = 0
      else if @xValue is @settings.xMaxValue
        arrowOffsetX = @_barWidth - 1
      else
        xMax = @settings.xMaxValue
        xMax = xMax + Math.abs(@settings.xMinValue) + 1  if @settings.xMinValue < 1
        xValue = @xValue
        xValue = xValue + 1  if @xValue < 1
        arrowOffsetX = xValue / xMax * @_barWidth
        if parseInt(arrowOffsetX) is (xMax - 1)
          arrowOffsetX = xMax
        else
          arrowOffsetX = parseInt(arrowOffsetX)
        arrowOffsetX = arrowOffsetX - Math.abs(@settings.xMinValue) - 1  if @settings.xMinValue < 1
    unless @settings.yMinValue is @settings.yMaxValue
      if @yValue is @settings.yMinValue
        arrowOffsetY = 0
      else if @yValue is @settings.yMaxValue
        arrowOffsetY = @_barHeight - 1
      else
        yMax = @settings.yMaxValue
        yMax = yMax + Math.abs(@settings.yMinValue) + 1  if @settings.yMinValue < 1
        yValue = @yValue
        yValue = yValue + 1  if @yValue < 1
        arrowOffsetY = yValue / yMax * @_barHeight
        if parseInt(arrowOffsetY) is (yMax - 1)
          arrowOffsetY = yMax
        else
          arrowOffsetY = parseInt(arrowOffsetY)
        arrowOffsetY = arrowOffsetY - Math.abs(@settings.yMinValue) - 1  if @settings.yMinValue < 1
    @_setArrowPosition arrowOffsetX, arrowOffsetY

  _setArrowPosition: (offsetX, offsetY) ->
    offsetX = 0  if offsetX < 0
    offsetX = @_barWidth  if offsetX > @_barWidth
    offsetY = 0  if offsetY < 0
    offsetY = @_barHeight  if offsetY > @_barHeight
    posX = @_barLeft + offsetX
    posY = @_barTop + offsetY
    if @_arrowWidth > @_barWidth
      posX = posX - (@_arrowWidth / 2 - @_barWidth / 2)
    else
      posX = posX - parseInt(@_arrowWidth / 2)
    if @_arrowHeight > @_barHeight
      posY = posY - (@_arrowHeight / 2 - @_barHeight / 2)
    else
      posY = posY - parseInt(@_arrowHeight / 2)
    @_arrow.css
      left: posX + 'px'
      top: posY + 'px'

  _mouseDown: (e) ->
    $.refresh.Web.ActiveSlider = this
    @setValuesFromMousePosition e
    document.mousemove @_event_docMouseMove
    documentmouseup @_event_docMouseUp
    Event.stop e

  _bar_mouseDown: (e) ->
    @_mouseDown e

  _arrow_mouseDown: (e) ->
    @_mouseDown e

  _docMouseMove: (e) ->
    @setValuesFromMousePosition e
    Event.stop e

  _docMouseUp: (e) ->
    document.unbind 'mouseup', @_event_docMouseUp
    document.unbind 'mousemove', @_event_docMouseMove
    Event.stop e

  setValuesFromMousePosition: (e) ->
    mouse = Event.pointer(e)
    relativeX = 0
    relativeY = 0
    if mouse.x < @_barLeft
      relativeX = 0
    else if mouse.x > @_barRight
      relativeX = @_barWidth
    else
      relativeX = mouse.x - @_barLeft + 1
    if mouse.y < @_barTop
      relativeY = 0
    else if mouse.y > @_barBottom
      relativeY = @_barHeight
    else
      relativeY = mouse.y - @_barTop + 1
    newXValue = parseInt(relativeX / @_barWidth * @settings.xMaxValue)
    newYValue = parseInt(relativeY / @_barHeight * @settings.yMaxValue)
    @xValue = newXValue
    @yValue = newYValue
    relativeX = 0  if @settings.xMaxValue is @settings.xMinValue
    relativeY = 0  if @settings.yMaxValue is @settings.yMinValue
    @_setArrowPosition relativeX, relativeY
    @onValuesChanged this  if @onValuesChanged
$.refresh.Web.Color = (init) ->
  color =
    r: 0
    g: 0
    b: 0
    h: 0
    s: 0
    v: 0
    hex: ""
    setRgb: (r, g, b) ->
      @r = r
      @g = g
      @b = b
      newHsv = $.refresh.Web.ColorMethods.rgbToHsv(this)
      @h = newHsv.h
      @s = newHsv.s
      @v = newHsv.v
      @hex = $.refresh.Web.ColorMethods.rgbToHex(this)

    setHsv: (h, s, v) ->
      @h = h
      @s = s
      @v = v
      newRgb = $.refresh.Web.ColorMethods.hsvToRgb(this)
      @r = newRgb.r
      @g = newRgb.g
      @b = newRgb.b
      @hex = $.refresh.Web.ColorMethods.rgbToHex(newRgb)

    setHex: (hex) ->
      @hex = hex
      newRgb = $.refresh.Web.ColorMethods.hexToRgb(@hex)
      @r = newRgb.r
      @g = newRgb.g
      @b = newRgb.b
      newHsv = $.refresh.Web.ColorMethods.rgbToHsv(newRgb)
      @h = newHsv.h
      @s = newHsv.s
      @v = newHsv.v

  if init
    if init.hex
      color.setHex init.hex
    else if init.r
      color.setRgb init.r, init.g, init.b
    else color.setHsv init.h, init.s, init.v  if init.h
  color

$.refresh.Web.ColorMethods =
  hexToRgb: (hex) ->
    hex = @validateHex(hex)
    r = "00"
    g = "00"
    b = "00"
    if hex.length is 6
      r = hex.substring(0, 2)
      g = hex.substring(2, 4)
      b = hex.substring(4, 6)
    else
      if hex.length > 4
        r = hex.substring(4, hex.length)
        hex = hex.substring(0, 4)
      if hex.length > 2
        g = hex.substring(2, hex.length)
        hex = hex.substring(0, 2)
      b = hex.substring(0, hex.length)  if hex.length > 0
    r: @hexToInt(r)
    g: @hexToInt(g)
    b: @hexToInt(b)

  validateHex: (hex) ->
    hex = new String(hex).toUpperCase()
    hex = hex.replace(/[^A-F0-9]/g, "0")
    hex = hex.substring(0, 6)  if hex.length > 6
    hex

  webSafeDec: (dec) ->
    dec = Math.round(dec / 51)
    dec *= 51
    dec

  hexToWebSafe: (hex) ->
    r = undefined
    g = undefined
    b = undefined
    if hex.length is 3
      r = hex.substring(0, 1)
      g = hex.substring(1, 1)
      b = hex.substring(2, 1)
    else
      r = hex.substring(0, 2)
      g = hex.substring(2, 4)
      b = hex.substring(4, 6)
    intToHex(@webSafeDec(@hexToInt(r))) + @intToHex(@webSafeDec(@hexToInt(g))) + @intToHex(@webSafeDec(@hexToInt(b)))

  rgbToWebSafe: (rgb) ->
    r: @webSafeDec(rgb.r)
    g: @webSafeDec(rgb.g)
    b: @webSafeDec(rgb.b)

  rgbToHex: (rgb) ->
    @intToHex(rgb.r) + @intToHex(rgb.g) + @intToHex(rgb.b)

  intToHex: (dec) ->
    result = (parseInt(dec).toString(16))
    result = ("0" + result)  if result.length is 1
    result.toUpperCase()

  hexToInt: (hex) ->
    parseInt hex, 16

  rgbToHsv: (rgb) ->
    r = rgb.r / 255
    g = rgb.g / 255
    b = rgb.b / 255
    hsv =
      h: 0
      s: 0
      v: 0

    min = 0
    max = 0
    if r >= g and r >= b
      max = r
      min = (if (g > b) then b else g)
    else if g >= b and g >= r
      max = g
      min = (if (r > b) then b else r)
    else
      max = b
      min = (if (g > r) then r else g)
    hsv.v = max
    hsv.s = (if (max) then ((max - min) / max) else 0)
    unless hsv.s
      hsv.h = 0
    else
      delta = max - min
      if r is max
        hsv.h = (g - b) / delta
      else if g is max
        hsv.h = 2 + (b - r) / delta
      else
        hsv.h = 4 + (r - g) / delta
      hsv.h = parseInt(hsv.h * 60)
      hsv.h += 360  if hsv.h < 0
    hsv.s = parseInt(hsv.s * 100)
    hsv.v = parseInt(hsv.v * 100)
    hsv

  hsvToRgb: (hsv) ->
    rgb =
      r: 0
      g: 0
      b: 0

    h = hsv.h
    s = hsv.s
    v = hsv.v
    if s is 0
      if v is 0
        rgb.r = rgb.g = rgb.b = 0
      else
        rgb.r = rgb.g = rgb.b = parseInt(v * 255 / 100)
    else
      h = 0  if h is 360
      h /= 60
      s = s / 100
      v = v / 100
      i = parseInt(h)
      f = h - i
      p = v * (1 - s)
      q = v * (1 - (s * f))
      t = v * (1 - (s * (1 - f)))
      switch i
        when 0
          rgb.r = v
          rgb.g = t
          rgb.b = p
        when 1
          rgb.r = q
          rgb.g = v
          rgb.b = p
        when 2
          rgb.r = p
          rgb.g = v
          rgb.b = t
        when 3
          rgb.r = p
          rgb.g = q
          rgb.b = v
        when 4
          rgb.r = t
          rgb.g = p
          rgb.b = v
        when 5
          rgb.r = v
          rgb.g = p
          rgb.b = q
      rgb.r = parseInt(rgb.r * 255)
      rgb.g = parseInt(rgb.g * 255)
      rgb.b = parseInt(rgb.b * 255)
    rgb