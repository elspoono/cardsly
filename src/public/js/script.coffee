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

  ###
  Loop through the buttons passed in.

  Buttons will be passed in as an array of objects. Each object with label string and action function

  settings.buttons = [
    {
      label: 'Button 1'
      action: function(){ alert('Button 1 clicked')}
    },
    {
      label: 'Button 2'
      action: function(){ alert('Button 2 clicked')}
    }
  ]
  ###
  if settings.buttons
    for i in settings.buttons
      thisButton = $ '<input type="button" class="button" value="'+i.label+'" class="submit">'
      if i.class
        thisButton.addClass i.class
      else
        thisButton.addClass 'normal'
      thisButton.click () ->
        i.action myNext
      buttons.append thisButton

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
    buttons: [
      action: (close) -> close()
      label: 'Ok'
    ]
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


###
 * jQuery Cookie plugin
 *
 * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
###
jQuery.cookie = (key, value, options) ->

  # key and at least value given, set cookie...
  if arguments.length > 1 && String(value) != "[object Object]"
    options = jQuery.extend {}, options
    if value == null || value == undefined
      options.expires = -1
    if typeof options.expires == 'number'
      days = options.expires
      t = options.expires = new Date()
      t.setDate t.getDate() + days

    value = String value

    document.cookie = [
      encodeURIComponent(key), '=',
      if options.raw then value else encodeURIComponent(value),
      if options.expires then '; expires=' + options.expires.toUTCString() else '', # use expires attribute, max-age is not supported by IE
      if options.path then '; path=' + options.path else 'path=/',
      if options.domain then '; domain=' + options.domain else '',
      if options.secure then '; secure' else ''
    ].join('')

  # key and possibly options given, get cookie...
  options = value || {}
  decode =  if options.raw  then (s) ->  s  else decodeURIComponent
  if (result = new RegExp('(?:^| )' + encodeURIComponent(key) + '=([^]*)').exec(document.cookie)) then decode(result[1]) else null


# Box rotate anything you want a lil bit
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




###


THIS IS WHERE REAL CODE STARTS

The 
$ ->

  Means everything under him (like me, indented here)
  WILL be done on document ready event.



###

$ ->



  ###
  Profile MENU in the TOP RIGHT
  Thing that shows a drop down
  ###
  $a = $ '.account-link'
  $am = $a.find '.account-menu'
  $body = $(document)
  $('.small-nav li').hover ->
    $(this).addClass 'hover'
  , ->
    $(this).removeClass 'hover'
  closeMenu = (e) ->
    $t = $ e.target
    if $t.closest('.account-link').length
      $a = $t.closest('li').find 'a'
      document.location.href = $a.attr 'href'
    else
      $a.removeClass 'click'
      $am.slideUp()
      $a.one 'click', expandMenu
      $body.unbind 'click', closeMenu
    false
  expandMenu = ->
    $am.slideDown()
    $a.addClass 'click'
    $body.bind 'click', closeMenu
    false
  $a.one 'click', expandMenu




  # One Line Comment

  ###
  Multiple
  Lines Of
  Comments
  ###





  # Path we'll use a few places, it's just the page we're on now, yeah?
  path = document.location.href.replace /http:\/\/[^\/]*/ig, ''

  #
  # Get Started Button Scroll
  $('.design-button').click ->
    if path != '/'
      document.location.href = '/#design-button'
    else
      $('html,body').animate
        scrollTop: $('.section:eq(1)').offset().top
      ,
      500
    false

  #
  # And again, on the home page, if we were passed the hash, scroll down!
  if path == '/#design-button'
    document.location.href = '#'
    $('.design-button').click()


  ###
  
  All the stuff for the admin template designer
  is probably going to be in this section right here.

  ok.

  ###
  #
  # Only an admin page, do this stuff
  if path == '/admin'

    # Grab all the guys we're going to use
    $designer = $ '.designer'
    #
    $card = $designer.find '.card'
    $qr = $card.find '.qr'
    $lines = $card.find '.line'
    $body = $ document
    #
    $cat = $designer.find '.category-field input'
    #
    $color1 = $designer.find '.color1'
    $color2 = $designer.find '.color2'
    #
    $fonts = $designer.find '.font-style'
    $font_color = $fonts.find '.color'
    $font_family = $fonts.find '.font-family'
    #
    $dForm = $designer.find 'form'
    $upload = $dForm.find '[type=file]'
    #
    # Set some constants
    card_height = $card.outerHeight()
    card_width = $card.outerWidth()
    card_inner_height = $card.height()
    card_inner_width = $card.width()
    active_theme = false
    #
    #
    # QRs and Lines are hidden By default
    $qr.hide()
    $lines.hide()
    #
    # Key up and down events for active lines
    shiftAmount = 1
    $body.keydown (e) ->
      $active_item = $card.find '.active'
      c = e.keyCode
      #
      # Only if we have a live one, do we do anything with this
      if $active_item.length and not $font_color.is(':focus') and not $font_family.is(':focus')
        #
        # Modify the amount we shift when the shift key is pressed :D
        # (apparently I like using confusing variable names, ha)
        if e.keyCode is 16 then shiftAmount = 10
        #
        # Up and Down Events
        if c is 38 or c is 40
          #
          # Find out how far the user asked to move
          new_top = parseInt($active_item.css('top'))
          if c is 38 then new_top -= shiftAmount
          if c is 40 then new_top += shiftAmount
          #
          # Find out our boundary
          top_bound = (card_height - card_inner_height)/2
          bottom_bound = top_bound + card_inner_height - $active_item.outerHeight()
          #
          # And then of course, "bound" it
          # We want to move clear to the max, so we still do it
          if new_top < top_bound then new_top = top_bound
          if new_top > bottom_bound then new_top = bottom_bound
          #
          # Then set it
          $active_item.css 'top', new_top
        #
        # Left and Right
        if c is 37 or c is 39
          #
          # Find out how far the user asked to move
          new_left = parseInt($active_item.css('left'))
          if c is 37 then new_left -= shiftAmount
          if c is 39 then new_left += shiftAmount
          #
          # Find out our boundary
          top_bound = (card_width - card_inner_width)/2
          bottom_bound = top_bound + card_inner_width - $active_item.outerWidth()
          #
          # And then of course, "bound" it
          # We want to move clear to the max, so we still do it
          if new_left < top_bound then new_left = top_bound
          if new_left > bottom_bound then new_left = bottom_bound
          #
          # Then set it
          $active_item.css 'left', new_left
        #
        # Always return false on the arrow key presses
        if c is 38 or c is 40 or c is 39 or c is 37 then return false
    $body.keyup (e) ->
      if e.keyCode is 16 then shiftAmount = 1
    #
    # Changing font color on key presses
    $font_color.keyup ->
      $t = $ this
      $active_item = $card.find('.active')
      #
      # Find it's index relative to it's peers
      index = $active_item.prevAll().length
      #
      # Update it all
      $active_item.css
        color: '#'+$t.val()
      active_theme.positions[index+1].color = $t.val()
    #
    # Helper function for highlighting going away
    unfocus_highlight = (e) ->
      $t = $ e.target
      if $t.hasClass('font-style') or $t.closest('.font-style').length or $t.hasClass('line') or $t.hasClass('qr') or $t.closest('.line').length or $t.closest('.qr').length
        true
      else
        $card.find('.active').removeClass 'active'
        $body.unbind 'click', unfocus_highlight
        $fonts.hide()
      false
    #
    # Highlighting and making a line the active one
    $lines.mousedown ->
      #
      # Set it up and make it active
      $t = $ this
      $pa = $card.find '.active'
      $pa.removeClass 'active'
      $t.addClass 'active'
      #
      # Allow body clicks to unfocus it
      $body.bind 'click', unfocus_highlight
      #
      # Find it's index relative to it's peers
      index = $t.prevAll().length
      $fonts.show()
      $font_color.val active_theme.positions[index+1].color
    #
    # Highlighting and making a line the active one
    $qr.mousedown ->
      $t = $ this
      $pa = $card.find '.active'
      $pa.removeClass 'active'
      $t.addClass 'active'
      $body.bind 'click', unfocus_highlight
      $fonts.hide()

    #
    # The dragging and dropping functions for lines
    $lines.draggable
      grid: [10,10]
      containment: '.designer .card'
    $lines.resizable
      grid: 10
      handles: 'n, e, s, w, se'
      resize: (e, ui) ->
        $(ui.element).css
          'font-size': ui.size.height + 'px'
          'line-height': ui.size.height + 'px'
    #
    # Dragging and dropping functions for the qr code
    $qr.draggable
      grid: [5,5]
      containment: '.designer .card'
    $qr.resizable
      grid: 5
      containment: '.designer .card'
      handles: 'n, e, s, w, ne, nw, se, sw'
      aspectRatio: 1
    #

    #
    # On upload selection, submit that form
    $upload.change ->
      $dForm.submit()

    #
    # 6 and 12 selectors in the thumbnails
    $('.theme-1,.theme-2').click ->
      $t = $ this
      $c = $t.closest '.card'

      $c.click()

      # Actual Switch the classes
      $('.theme-1,.theme-2').removeClass 'active'
      $t.addClass 'active'

      # always return false to prevent href from going anywhere
      false

    #
    # Helper Function for getting the position in percentage from an elements top, left, height and width
    getPosition = ($t) ->
      # Get it's CSS Values
      height = parseInt $t.height()
      width = parseInt $t.width()
      left = parseInt $t.css 'left'
      top = parseInt $t.css 'top'
      #
      # Stop me if something went wrong :)
      if isNaN(height) or isNaN(width) or isNaN(top) or isNaN(left)
         return false
      #
      # Calculate a percentage and send it
      result = 
        h: Math.round(height / card_height * 10000) / 100
        w: Math.round(width / card_width * 10000) / 100
        x: Math.round(left / card_width * 10000) / 100
        y: Math.round(top / card_height * 10000) / 100
    #
    # Do the actual save.
    #
    # It should be noted, that in most cases, this just means saving into the session
    # Only on save button click does it pass an extra parameter to save it to a record in the database
    execute_save = (next) ->
      theme =
        _id: active_theme._id
        category: $cat.val()
        positions: []
        color1: $color1.val()
        color2: $color2.val()
        s3_id: active_theme.s3_id
      #
      # Get the position of the qr
      theme.positions.push getPosition $qr
      #
      # Get the position of each line
      $lines.each ->
        $t = $ this
        pos = getPosition $t
        if pos
          theme.positions.push pos
      #
      # Set the parameters
      parameters =
        theme: theme
        do_save: if next then true else false
      #
      $.ajax
        url: '/saveTheme'
        #
        # jQuery's default data parser does well with simple objects, but with complex ones it doesn't do quite what we need.
        # So in this case, we need to stringify first, doing our own conversion to a string to transmit across the 
        # interwebs to our server.
        #
        # (and correspondingly, the server does a JSON parse of the raw body instead of it's usual parsing.)
        data: JSON.stringify parameters
        success: (serverResponse) ->
          if !serverResponse.success
            $designer.find('.save').showTooltip
              message: 'Error saving.'
          if next then next()
        error: ->
          $designer.find('.save').showTooltip
            message: 'Error saving.'
          if next then next()


    #
    # A global page timer for the automatic save event.
    pageTimer = 0
    setPageTimer = ->
      clearTimeout pageTimer
      pageTimer = setTimeout ->
        execute_save()
      , 500 # This will be 5000 or higher eventually, 500 for now for testing. I'm impatient :D :D :D

    #
    # Set that timer on the right events for the right things
    $cat.keyup setPageTimer
    $color1.keyup setPageTimer
    $color2.keyup setPageTimer

    $.s3_result = (s3_id) ->
      if not noTheme() and s3_id
        active_theme.s3_id = s3_id
        $card.css
          background: 'url(\'http://cdn.cards.ly/525x300/' + s3_id + '\')'
      else
        loadAlert
          content: 'I had trouble saving that image, please try again later.'

    #
    # Function that is called to verify a theme is selected, warns if not.
    noTheme = ->
      if !active_theme
        loadAlert
          content: 'Please create or select a theme first'
        true
      else
        false

    #
    # Default Template for Card Designer
    default_theme = 
      category: ''
      color1: 'FFFFFF'
      color2: '000000'
      s3_id: ''
      positions: [
        h: 45
        w: 45
        x: 70
        y: 40
      ]
    for i in [0..5]
      default_theme.positions.push
        color: '000000'
        font_family: 'Arial'
        h: 7
        w: 50
        x: 5
        y: 5+i*10
    #
    # The general load theme function
    # It's for putting a theme into the designer for editing
    loadTheme = (theme) ->
      active_theme = theme
      qr = theme.positions.shift()
      $qr.show().css
        top: qr.y/100 * card_height
        left: qr.x/100 * card_width
        height: qr.h/100 * card_height
        width: qr.w/100 * card_height
      for pos,i in theme.positions
        $li = $lines.eq i
        $li.show().css
          top: pos.y/100 * card_height
          left: pos.x/100 * card_width
          width: (pos.w/100 * card_width) + 'px'
          fontSize: (pos.h/100 * card_height) + 'px'
          lineHeight: (pos.h/100 * card_height) + 'px'
          fontFamily: pos.font_family
          color: '#'+pos.color
      theme.positions.unshift qr
      $cat.val theme.category
      $color1.val theme.color1
      $color2.val theme.color2
    #
    # The add new button
    $('.add-new').click ->
      loadTheme(default_theme)

      # Oh wait, this doesn't happen until save, eh?
      ###
      $new_li = $ '<li class="card" />'
      $('.category[category=""] .gallery').append $new_li
      $new_li.click()
      ###


    #
    # On save click
    $designer.find('.buttons .save').click ->
      # Make sure we have something selected.
      if noTheme() then return false
      
      loadLoading {}, (closeLoading) ->
        execute_save ->
          closeLoading()
    #
    # On delete click
    $designer.find('.buttons .delete').click ->
      if noTheme() then return false
      loadModal
        content: '<p>Are you sure you want to permanently delete this template?</p>'
        height: 160
        width: 440
        buttons: [{
          label: 'Delete'
          action: (closeFunc) ->
            ###
            TODO: Make this delete the template

            So send to the server to delete the template we're on here ...

            ###
            closeFunc()
          },{
          class: 'gray'
          label: 'Cancel'
          action: (closeFunc) ->
            closeFunc()
          }
        ]
    
  #
  # Successful Login Function
  successfulLogin = ->
    if path == '/login'
      document.location.href = '/admin'
    else
      $s = $ '.signins' 
      $s.fadeOut 500, ->
        $s.html 'You are now logged in, please continue.'
        $s.fadeIn 1000
      $('.login a').attr('href','/logout').html 'Logout'


  # Window and Main Card to use later
  $win = $ window
  $mc = $ '.main.card'

  # Set up the hasHidden array with all of non visible sections
  winH = $win.height()+$win.scrollTop()
  hasHidden = []
  $('.section-to-hide').each ->
    $this = $(this)
    thisT = $this.offset().top
    if(winH<thisT)
      hasHidden.push
        $this: $this
        thisT: thisT
  # Hide them
  for i in hasHidden
    i.$this.hide()
  

  ###
  Update Cards

  This is used each time we need to update all the cards on the home page with the new content that's typed in.
  ###
  updateCards = (rowNumber, value) ->
    $('.card .content').each -> $(this).find('li:eq('+rowNumber+')').html value


  # On the window scroll event ...
  $win.scroll ->

    # Get the new bottom of the window position
    newWinH = $win.height()+$win.scrollTop()
    if $mc.length
      # If the main card bottom is now visible
      if $mc.offset().top+$mc.height() < newWinH && !$mc.data 'didLoad'
        $mc.data 'didLoad', true
        timeLapse = 0
        $('.main.card').find('input').each (rowNumber) ->
          updateCards rowNumber, this.value
        $('.main.card .defaults').find('input').each (rowNumber) ->
          $t = $ this
          v = $t.val()
          $t.val ''
          timers = for j in [0..v.length]
            do (j) ->
              timer = setTimeout ->
                v_substring = v.substr 0,j
                $t.val v_substring
                updateCards rowNumber, v_substring
              ,timeLapse*70
              timeLapse++
              timer
          $t.bind 'clearMe', ->
            console.log $t.data 'cleared'
            if !$t.data 'cleared'
              for i in timers
                clearTimeout i
              $t.val ''
              updateCards rowNumber, ''
              $t.data 'cleared', true
          $t.bind 'focus', ->
            $t.trigger 'clearMe'


    # Show any hidden sections
    for i in hasHidden
      if i.thisT-50 < newWinH
        i.$this.fadeIn(2000)
  
  

  #loadAlert 'Test', (close) ->
    #close()
  
  ###
  Login stuff
  ###
  #
  #
  # Watch the popup windows every 200ms for when they set a cookie
  monitorForComplete = (openedWindow) ->
    $.cookie 'success-login', null
    checkTimer = setInterval ->
      if $.cookie 'success-login'
        successfulLogin()
        $.cookie 'success-login', null
        window.focus()
        openedWindow.close()
    ,200
  #
  # Specific Socials Setup
  $('.google').click () ->
    monitorForComplete window.open 'auth/google', 'auth', 'height=350,width=600'
    false
  $('.twitter').click () ->
    monitorForComplete window.open 'auth/twitter', 'auth', 'height=400,width=500'
    false
  $('.facebook').click () ->
    monitorForComplete window.open 'auth/facebook', 'auth', 'height=400,width=900'
    false
  $('.linkedin').click () ->
    monitorForComplete window.open 'auth/linkedin', 'auth', 'height=300,width=400'
    false
  #
  #
  #Regular Login
  $('.login-form').submit ->
    loadLoading {}, (loadingClose) ->
      $.ajax
        url: '/login'
        data:
          email: $('.email-login').val()
          password: $('.password-login').val()
        success: (data) ->
          loadingClose()
          if data.err
            loadAlert
              content: data.err
          else
            successfulLogin()
        error: (err) ->
          loadingClose()
          loadAlert
            content: 'Our apologies. A server error occurred.'
    false
  #
  # New Login Creation
  $('.new').click () ->
    loadModal
      content: '<div class="create-form"><p>Email Address:<br><input class="email"></p><p>Password:<br><input type="password" class="password"></p></p><p>Repeat Password:<br><input type="password" class="password2"></p></div>'
      buttons: [
        label: 'Create New'
        action: (formClose) ->
          email = $ '.email'
          password = $ '.password'
          password2 = $ '.password2'

          err = false
          if email.val() == '' || password.val() == '' || password2.val() == ''
            err = 'Please enter an email once and the password twice.'
          else if password.val() != password2.val()
            err = 'I\'m sorry, I don\'t think those passwords match.'
          else if password.val().length<4
            err = 'Password should be a little longer, at least 4 characters.'
          if err
            loadAlert {content:err}
          else
            formClose()
            loadLoading {}, (loadingClose) ->
              $.ajax
                url: '/createUser'
                data:
                  email: email.val()
                  password: password.val()
                success: (data) ->
                  loadingClose()
                  if data.err
                    loadAlert
                      content: data.err
                  else
                    successfulLogin()
                error: (err) ->
                  loadingClose()
                  loadAlert
                    content: 'Our apologies. A server error occurred.'
              , 1000
      ]
      height: 340
      width: 400
    
    $('.email').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val().match /.{1,}@.{1,}\..{1,}/
          $t.removeClass('error').addClass 'valid'
          $.ajax
            url: '/checkEmail'
            data:
              email: $t.val()
            success: (fullResponseObject) ->
              if fullResponseObject.count==0
                $t.removeClass('error').addClass 'valid'
                $t.showTooltip
                  message: fullResponseObject.email+' is good'
              else
                $t.removeClass('valid').addClass 'error'
                $t.showTooltip
                  message:''+fullResponseObject.email+' is in use. Try signing in with a social login.'
        else
          $t.removeClass('valid').addClass('error').showTooltip
            message: 'Is that an email?'
      ,1000
    $('.password').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val().length >= 4
          $t.removeClass('error').addClass 'valid'
        else
          $t.removeClass('valid').addClass('error').showTooltip
            message: 'Just '+(6-$t.val().length)+' more characters please.'
      ,1000
    $('.password2').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val() == $('.password').val()
          $t.removeClass('error').addClass 'valid'
          $('.step-4').fadeTo 300, 1
        else
          $t.removeClass('valid').addClass('error').showTooltip
            message:'Passwords should match please.'
      ,1000
    false
 
  $feedback_a = $ '.feedback a'
  $feedback_a.mouseover () ->
    $feedback = $ '.feedback'
    $feedback.stop(true,false).animate
      right: '-37px'
      ,250
  $feedback_a.mouseout () ->
    $feedback = $ '.feedback'
    $feedback.stop(true,false).animate
      right: '-45px'
      ,250

      
    
  $feedback_a.click () ->
    loadModal
      content: '<div class="feedback-form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback-text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email" cols="40"></p></div>'
      width: 400
      height: 300
      buttons: [
        label: 'Send Feedback'
        action: (formClose) ->
          #Close the window
          formClose()
          loadLoading {}, (loadingClose) ->
            $.ajax
              url: '/sendFeedback'
              data:
                content: $('.feedback-text').val()
                email: $('.emailNotUser').val()
              success: (data) ->
                loadingClose()
                if data.err
                  loadAlert
                    content: data.err
                else
                  successfulFeedback() ->
                    $s.html 'Feedback Sent'
                    $s.fadeIn 100000
              error: (err) ->
                loadingClose()
                loadAlert
                  content: 'Our apologies. A server error occurred, feedback could not be sent.'
            , 1000
      ] 
    false
  # This is the code that makes the dropdown menu changes which chart is displayed on the account page

  $('#show_activity').change () ->
    $('#activity_container ul').hide('slow')
    e='#' + $(':selected', $(this)).attr 'name'
    $(e).show('slow')
  $('#activity_container ul').hide()

  #This is the code to make which card chart is dispaled based on the dropdown menu
  $('#show_card_chart').change () ->
    $('#chart_container ul').hide('slow')
    e='#' + $(':selected', $(this)).attr 'name'
    $(e).show('slow')
  $('#chart_container ul').hide()

         
  ###
  Shopping Cart Stuff
  ###
  #
  # Default Item Name
  item_name = '100 cards'
  #
  # Checkout button action, default error for now.
  $('.checkout').click () ->
    loadAlert
      content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
    false
  #
  # The floaty guy behind the gallery selection
  $gs = $ '.gallery-select'
  $gs.css
    left: -220
    top: 0
  $('.gallery .card').live 'click', () ->
    $t = $ this
    $('.card').removeClass 'active'
    $t.addClass('active')
    $findClass = $t.clone()
    className = $findClass.removeClass('card')[0].className
    $findClass.remove()
    $('.main').attr
      class: 'card main '+className
    if $gs.offset().top == $t.offset().top-10
      $gs.animate
        left: $t.offset().left-10
      ,500
    else
      $gs.stop(true,false).animate
        top: $t.offset().top-10
      ,500,'linear',() ->
          $gs.animate
            left: $t.offset().left-10
          ,500,'linear'
  $gs.bind 'activeMoved', ->
    $a = $ '.card.active'
    $gs.css
      left: $a.offset().left-10
      top: $a.offset().top-10
  $(window).load () ->
    $('.gallery:first .card:first').click()
  



  # Buttons everywhere need hover and click states
  $('.button').live 'mouseenter', ->
    $(this).addClass 'hover'
  .live 'mouseleave', ->
    $(this).removeClass 'hover'
  .live 'mousedown', ->
    $(this).addClass 'click'
  .live 'mouseup', ->
    $(this).removeClass 'click'

  # Define Margin
  newMargin = 0
  maxSlides = $('.slides li').length
  marginIncrement = 620
  maxSlides--

  ###
  # Home Page Stuff
  ###

  # 
  # Category Expand/Collapse
  $('.category h4').click () ->
    $t = $ this
    $c = $t.closest '.category'
    $g = $c.find '.gallery'
    $a = $ '.category.active'
    if !$c.hasClass 'active'
      $a.removeClass('active')
      $a.find('.gallery').show().slideUp 400
      $gs.hide()
      $c.find('.gallery').slideDown 400, ->
        $gs.show()
        $c.find('.card:first').click()
      $c.addClass('active')

  #
  # Form Fields
  $('.card.main input').each (i) ->
    $t = $ this
    $t.data 'timer', 0
    $t.keyup -> 
      updateCards i, this.value
      clearTimeout $t.data 'timer'
      $t.data 'timer',
        setTimeout ->
          $('.card.main input').each -> $(this).trigger 'clearMe'
          ###
          # TODO
          #
          # this.value should have a .replace ',' '\,'
          # on it so that we can use a comma character and escape anything.
          # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
          ###
          arrayOfInputValues = $.makeArray $('.card.main input').map -> this.value
          console.log arrayOfInputValues
          $.ajax
            url: '/saveForm'
            data:
              inputs: arrayOfInputValues.join('`~`')
          false
        ,1000
      false
  
  ###
  # Button Clicking Stuff
  ###
  #
  # Radio Select
  $('.quantity input,.shipping_method input').bind 'click change', () ->
    $q = $('.quantity input:checked')
    $s = $('.shipping_method input:checked')
    $('.order-total .price').html '$'+($q.val()*1 + $s.val()*1)


  # Show / Hide more fields
  $('.main-fields .more').click ->
    $('.main-fields .alt').slideDown 500, 'linear', () ->
      $('.gallery .card.active').click()
    $(this).hide()
    $('.main-fields .less').show()
    false
  $('.main-fields .less').hide().click ->
    $('.main-fields .alt').slideUp 500, 'linear', () ->
      $('.gallery .card.active').click()
    $(this).hide()
    $('.main-fields .more').show()
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