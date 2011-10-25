

###
 * 
 * Set settings / defaults
 * 
 * AJAX defaults
 * some constants
 * 
###
$.ajaxSetup
  type: 'POST'
usualDelay = 4000
$window = $ window 
$.fx.speeds._default = 300

###
 * 
 * Modal Handling Functions
 * 
 * show tooltip, can be used on any element with jquery
 * 
 * 
###
$.fn.showTooltip = (options) ->
  settings = 
    position: 'below'
  this.each (i) ->
    if options
      $.extend settings, options

    $t = $(this)
    offset = $t.offset()
    data = $t.data 'tooltips'
    if !data
      data = []
    if settings.message
      tooltip = $('<div class="tooltip" />')
      tooltip.html settings.message
      tooltip.css
        left: offset.left
        top: offset.top + ( if settings.position=='below' then $t.height()+40 else 0 )
      $('body').append tooltip
      for i in data
        i.stop(true,true).fadeOut()
      data.push tooltip
      if data.length > 5
        toRemove = data.shift()
        toRemove.remove()
      $t.data 'tooltips', data
    else
      tooltip = data[data.length-1]
    ###

        TODO : Make the animation in a custom slide up / slide down thing with $.animate

    ###
    tooltip.stop(true,true).fadeIn().delay(usualDelay).fadeOut()

###
   * 
   * Modal Handling Functions
   * 
   * Basic load
   * 
   * 
###
loadModal = (options, next) ->

  scrollbarWidth = $.scrollbarWidth()
  modal = $('<div class="modal" />')
  win = $('<div class="window" />')
  close = $('<div class="close" />')

  settings =
    width: 500
    height: 235
    closeText: 'close'

  if options
    $.extend settings, options


  myNext = () ->
    $window.unbind 'scroll resize',resizeEvent
    $window.unbind 'resize',resizeEvent
    $body.css
      overflow:'inherit'
      'padding-right':0
    modal.fadeOut () -> modal.remove()
    close.fadeOut () -> close.remove()
    win.fadeOut () ->
      win.remove()
      if($('.window').length==0)
        $('#container').show()

  if settings.closeText
    close.html settings.closeText
  if settings.content
    win.html settings.content
  if settings.height
    win.css
      'min-height':settings.height
  if settings.width
    win.width settings.width

  buttons = $ '<div class="buttons" />'

  if settings.Close
    Close = $ '<input type="button" value="Close" class="submit">'
    Close.click () ->
      settings.Close myNext
    buttons.append Close

  if settings.Ok
    ok = $ '<input type="button" value="Ok" class="submit">'
    ok.click () ->
      settings.Ok myNext
    buttons.append ok

  if settings.Cancel
    cancel = $ '<input type="button" value="Cancel" class="cancel">'
    cancel.click () ->
      settings.Cancel myNext
    buttons.append cancel

  if settings.Confirm
    confirm = $ '<input type="button" value="Confirm" class="submit">'
    confirm.click () ->
      settings.Confirm myNext
    buttons.append confirm

  win.append buttons

  $('body').append modal,close,win


  $body = $('body')
  resizeEvent = () ->
    width = $window.width()
    height = $window.height()
    if width < settings.width || height < win.height()
      $window.unbind 'scroll resize',resizeEvent
      close.css
        position:'relative'
      win.width(width-60).css
        position:'relative'
      $('#container').hide()
      top = close.offset().top
      modal.css
        top:0
        left:0
        width:width
        height:top
      window.scroll 0,top
    else
      $body.css
        overflow:'hidden'
        'padding-right':scrollbarWidth
      win.position
        of:$window
        at:'center center'
        my:'center center'
        offset:'0 40px'
      modal.position
        of:$window
        at:'center center'
      close.position
        of:win
        at:'right top'
        my:'right bottom'
        offset:'0 0'

  $window.bind 'resize scroll', resizeEvent

  modal.click myNext
  close.click myNext
  width = $window.width()
  height = $window.height()
  if width < settings.width || height < win.height()
    modal.show()
    win.show()
    close.show()
  else
    modal.fadeIn()
    win.fadeIn()
    close.fadeIn()

  if next
    next myNext
  resizeEvent()

###
 * 
 * Modal Handling Functions
 * 
 * Load Loading (Subclass of loadmodal)
 * 
 * 
###
loadLoading = (options, next) ->
  options = options || {}
  modifiedOptions =
    content: 'Loading ... '
    height: 100
    width: 200

  for i,v of options
    modifiedOptions[i] = options[i]
  loadModal modifiedOptions, next

###
 * 
 * Modal Handling Functions
 * 
 * Load Confirm (Subclass of loadmodal)
 * like javascript confirm()
 * 
###
loadConfirm = (options, next) ->
  options = options || {}
  modifiedOptions =
    content: 'Confirm'
    height: 80
    width: 300
  for i,v of options
    modifiedOptions[i] = options[i]
  loadModal modifiedOptions, next

###
 * 
 * Modal Handling Functions
 * 
 * Load Alert (Subclass of loadmodal)
 * like javascript alert()
 * 
###
loadAlert = (options, next) ->
  options = options || {}
  next = next || () ->
  if typeof(options) == 'string'
    options = 
      content:options
  modifiedOptions =
    content: 'Alert'
    Ok: (close) -> close()
    height: 80
    width: 300
  for i,v of options
    modifiedOptions[i] = options[i]
  loadModal modifiedOptions, next


###
 * jQuery Scrollbar Width v1.0
 * 
 * Copyright 2011, Rasmus Schultz
 * Licensed under LGPL v3.0
 * http:#www.gnu.org/licenses/lgpl-3.0.txt
###
$.scrollbarWidth = () ->
  if !$._scrollbarWidth
    $body = $ 'body'
    w = $body.css('overflow', 'hidden').width()
    $body.css('overflow','scroll')
    w -= $body.width()
    if !w
      w = $body.width() - $body[0].clientWidth
    $body.css 'overflow',''
    $._scrollbarWidth = w
  $._scrollbarWidth


###
#http:#stevenlevithan.com/assets/misc/date.format.js
 * Date Format 1.2.3
 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
 * MIT license
 *
 * Includes enhancements by Scott Trenda <scott.trenda.net>
 * and Kris Kowal <cixar.com/~kris.kowal/>
 *
 * Accepts a date, a mask, or a date and a mask.
 * Returns a formatted version of the given date.
 * The date defaults to the current date/time.
 * The mask defaults to dateFormat.masks.default.
###

class dateFormat

  token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g
  timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g
  timezoneClip = /[^-+\dA-Z]/g
  pad = (val, len) ->
    val = String(val)
    len = len || 2
    while val.length < len
      val = "0" + val
    val

  format: (date, mask, utc) ->
    dF = dateFormat.prototype

    # You can't provide utc if you skip other args (use the "UTC:" mask prefix)
    if arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)
      mask = date
      date = undefined

    # Passing date through Date applies Date.parse, if necessary
    date = if date then new Date(date) else new Date
    if isNaN(date) 
      throw SyntaxError "invalid date"

    mask = String dF.masks[mask] || mask || dF.masks["default"]

    # Allow setting the utc argument via the mask
    if mask.slice(0, 4) == "UTC:"
      mask = mask.slice(4)
      utc = true

    _ = if utc then "getUTC" else "get"
    d = date[_ + "Date"]()
    D = date[_ + "Day"]()
    m = date[_ + "Month"]()
    y = date[_ + "FullYear"]()
    H = date[_ + "Hours"]()
    M = date[_ + "Minutes"]()
    s = date[_ + "Seconds"]()
    L = date[_ + "Milliseconds"]()
    o = utc ? 0 : date.getTimezoneOffset()
    flags =
      d:    d
      dd:   pad d
      ddd:  dF.i18n.dayNames[D]
      dddd: dF.i18n.dayNames[D + 7]
      m:    m + 1
      mm:   pad m + 1
      mmm:  dF.i18n.monthNames[m]
      mmmm: dF.i18n.monthNames[m + 12]
      yy:   String(y).slice 2
      yyyy: y
      h:    H % 12 || 12
      hh:   pad H % 12 || 12
      H:    H
      HH:   pad H
      M:    M
      MM:   pad M
      s:    s
      ss:   pad s
      l:    pad L, 3
      L:    pad if L > 99 then Math.round L / 10 else L
      t:    if H < 12 then "a"  else "p"
      tt:   if H < 12 then "am" else "pm"
      T:    if H < 12 then "A"  else "P"
      TT:   if H < 12 then "AM" else "PM"
      Z:    if utc then "UTC" else (String(date).match(timezone) || [""]).pop().replace(timezoneClip, "")
      o:    (if o > 0 then "-" else "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4)
      S:    ["th", "st", "nd", "rd"][if d % 10 > 3 then 0 else (d % 100 - d % 10 != 10) * d % 10]


    mask.replace token, ($0) ->
      if flags then flags[$0] else $0.slice(1, $0.length - 1)

  # Some common format strings
  masks :
    default:      "ddd mmm dd yyyy HH:MM:ss"
    shortDate:      "m/d/yy"
    mediumDate:     "mmm d, yyyy"
    longDate:       "mmmm d, yyyy"
    fullDate:       "dddd, mmmm d, yyyy"
    shortTime:      "h:MM TT"
    mediumTime:     "h:MM:ss TT"
    longTime:       "h:MM:ss TT Z"
    isoDate:        "yyyy-mm-dd"
    isoTime:        "HH:MM:ss"
    isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss"
    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"


  # Internationalization strings
  i18n :
    dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


# For convenience...
Date::format = (mask, utc) ->
  a = new dateFormat
  a.format(this, mask, utc)

$.fn.box_rotate = (options) ->
  settings = 
    position: 'below'
  this.each (i) ->
    if options
      $.extend settings, options

    $t = $(this)
    degrees = settings.degrees
    rotate = Math.floor( (degrees/360)*100 )/100
    $t.css
      '-moz-transform':'rotate('+degrees+'deg)'
      '-webkit-transform':'rotate('+degrees+'deg)'
      '-o-transform':'rotate('+degrees+'deg)'
      '-ms-transform':'rotate('+degrees+'deg)'
      'filter:progid':'DXImageTransform.Microsoft.BasicImage(rotation='+rotate+')'

  
$ ->

  

  #loadAlert 'Test', (close) ->
    #close()

  $('.google').click () ->
    window.open 'auth/google', 'auth', 'height=350,width=600'
    false

  $('.twitter').click () ->
    window.open 'auth/twitter', 'auth', 'height=400,width=500'
    false

  $('.facebook').click () ->
    window.open 'auth/facebook', 'auth', 'height=400,width=900'
    false

  $('.linkedin').click () ->
    window.open 'auth/linkedin', 'auth', 'height=300,width=400'
    false

  $('.new').click () ->
    loadAlert
      content: '<iframe height=400 width=100% src=/login ></iframe>'
      height: 400
      width: 700
    false


  $win = $(window)
  winH = $win.height()+$win.scrollTop()
  hasHidden = []
  $('.section-to-hide').each ->
    $this = $(this)
    thisT = $this.offset().top
    if(winH<thisT)
      hasHidden.push
        $this: $this
        thisT: thisT
  for i in hasHidden
    i.$this.hide()
  $win.scroll ->
    newWinH = $win.height()+$win.scrollTop()
    for i in hasHidden
      if i.thisT-50 < newWinH
        i.$this.fadeIn(2000)


  # Buttons everywhere need hover and click states
  $('.button').hover ->
    $(this).addClass 'hover'
  ,->
    $(this).removeClass 'hover'
  .mousedown ->
    $(this).addClass 'click'
  .mouseup ->
    $(this).removeClass 'click'

  # Define Margin
  newMargin = 0
  maxSlides = 3
  marginIncrement = 620
  maxSlides--


  # Home Page Stuff

  # Form Fields
  $('.main-fields input').each () ->
    $t = $ this
    $t.keyup ->
      c = this.className
      v = this.value
      $('.card .'+c).html(v)

  # Moving Stuff
  $('.gallery').sortable
    item: '.card'
    connectWith: '.gallery'
  
  # Button Clicking Stuff

  # Move Button
  $('.move').click ->
    $t = $ this

    if $.browser.webkit
      $('.gallery .card').addClass('wiggle-animate')
    else
      clearTimeout($('.move').data 'timer')
      d = 0
      r = [-.5,-1,-.5,0,.5,1,.5,0]
      $t.data 'timer', setInterval ->
        d=d+1
        c = r[d%r.length]
        $('.gallery .card').box_rotate({degrees:c})
      ,30
    setTimeout ->
      clearDoc = ->
        clearTimeout($('.move').data 'timer')
        $('.gallery .card').removeClass('wiggle-animate').box_rotate({degrees:0})
        $('body').unbind 'click', clearDoc
      $('body').bind 'click', clearDoc
    ,0
    false

  # Show / Hide more fields
  $('.main-fields .more').click ->
    $('.main-fields .alt').slideDown 1000
    $(this).hide()
    $('.main-fields .less').show()
    false
  $('.main-fields .less').hide().click ->
    $('.main-fields .alt').slideUp 1000
    $(this).hide()
    $('.main-fields .more').show()
    false

  # Get Started Button Scroll
  $('.design-button').click ->
    $('html,body').animate
      scrollTop: $('.section:eq(1)').offset().top
    ,
    1000
    false

  # each advance of the slide
  advanceSlide = ->
    if newMargin < maxSlides * -marginIncrement
      newMargin=0
    else if newMargin > 0
      newMargin = maxSlides * -marginIncrement

    $('.slides .content').stop(true,false).animate
      'margin-left': newMargin
    , 400

  # click events
  $('.slides .arrow-right').click ->
    marginIncrement = $('.slides').width()
    clearTimeout(timer)
    newMargin -= marginIncrement
    advanceSlide()
  $('.slides .arrow-left').click ->
    marginIncrement = $('.slides').width()
    clearTimeout(timer)
    newMargin -= -marginIncrement
    advanceSlide()

  # The timer that starts and then repeats (cancelled on click)
  timer = setTimeout ->
    marginIncrement = $('.slides').width()
    newMargin -= marginIncrement
    advanceSlide()
    clearTimeout(timer)
    timer = setInterval ->
      marginIncrement = $('.slides').width()
      newMargin -= marginIncrement
      advanceSlide()
    , 6500
  , 3000