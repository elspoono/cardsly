

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
      thisButton = $ '<input type="button" class="button normal" value="'+i.label+'" class="submit">'
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
  #
  $fieldH = $ '.field input.height'
  $fieldW = $ '.field input.width'
  $fieldX = $ '.field input.x'
  $fieldY = $ '.field input.y'
  #
  # Default Template for Card Designer
  template = 
    category: 'Professional'
    themes: (
      qr_size: 45
      qr_x: 70
      qr_y: 40
      positions: (
        font_size:7/j
        width: 50
        x:5
        y:5+i/(j+1)*10
      ) for i in [0..5+j*6]
    ) for j in [0..1]
  #
  # Card Designer
  $designer = $ '.designer .card'
  dh = $designer.height()
  dw = $designer.width()
  #
  # The individual lines
  $lines = $designer.find '.line'
  updateStats = (e, ui) ->
    $fieldY.val Math.round(ui.position.top / dh * 10000) / 100 + '%'
    $fieldX.val Math.round(ui.position.left / dw * 10000) / 100 + '%'
    if ui.size
      $fieldH.val Math.round(ui.size.height / dh * 10000) / 100 + '%'
      $fieldW.val Math.round(ui.size.width / dw * 10000) / 100 + '%'
  $lines.draggable
    drag: updateStats
    grid: [5,5]
    containment: '.designer .card'
  $lines.resizable
    resize: updateStats
    grid: 5
  $lines.fitText()
  #
  # 
  $qr = $designer.find '.qr'
  $qr.draggable
    drag: updateStats
    grid: [5,5]
    containment: '.designer .card'
  $qr.resizable
    resize: updateStats
    grid: 5
    containment: '.designer .card'
    aspectRatio: 1
  #
  $lines.hide()
  for pos,i in template.themes[0].positions
    $li = $lines.eq i
    $li.show().css
      top: pos.y/100 * dh
      left: pos.x/100 * dw
      width: (pos.width/100 * dw) + 'px'
      fontSize: (pos.font_size/100 * dh) + 'px'
      lineHeight: (pos.font_size/100 * dh) + 'px'
  $qr.css
    top: template.themes[0].qr_y/100 * dh
    left: template.themes[0].qr_x/100 * dw
    height: template.themes[0].qr_size/100 * dh
    width: template.themes[0].qr_size/100 * dh
    

  
  $dForm = $ '.designer form'
  $upload = $dForm.find '[type=file]'
  $upload.change ->
    $dForm.submit()

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

  Function used a few places below
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
            success: (data) ->
              if data.data==0
                $t.removeClass('error').addClass 'valid'
                $t.showTooltip
                  message: data.email+' is good'
              else
                $t.removeClass('valid').addClass 'error'
                $t.showTooltip
                  message:''+data.email+' is in use. Try signing in with a social login.'
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
      content: '<p>Our apologies - we are still in development.<p>Please check back <span style="text-decoration:line-through;">next week</span> later this week.<p>(November 5th 2011)'
    false
  #
  # The floaty guy behind the gallery selection
  $gs = $ '.gallery-select'
  $gs.css
    left: -220
    top: 0
  $('.gallery .card').click () ->
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