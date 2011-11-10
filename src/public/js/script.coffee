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

# Splash Page Displays Different
if $.browser.msie and parseInt($.browser.version, 10)<8
    document.location.href = '/splash'




###
 * 
 * Modal Handling Functions
 * 
 * show tooltip, can be used on any element with jquery
 * 
 * 
###
$.fn.show_tooltip = (options) ->
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
      tooltip = data[data.length_1]
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
$.load_modal = (options, next) ->

  scrollbar_width = $.scrollbar_width()
  modal = $('<div class="modal" />')
  win = $('<div class="window" />')
  close = $('<div class="close" />')

  settings =
    width: 500
    height: 235
    closeText: 'close'

  if options
    $.extend settings, options


  my_next = () ->
    $window.unbind 'scroll resize',resize_event
    $window.unbind 'resize',resize_event
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
      this_button = $ '<input type="button" class="button" value="'+i.label+'" class="submit">'
      if i.class
        this_button.addClass i.class
      else
        this_button.addClass 'normal'
      this_button.click () ->
        i.action my_next
      buttons.append this_button

  win.append buttons

  $('body').append modal,close,win


  $body = $('body')
  resize_event = () ->
    width = $window.width()
    height = $window.height()
    if width < settings.width || height < win.height()
      $window.unbind 'scroll resize',resize_event
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
        'padding-right':scrollbar_width
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

  $window.bind 'resize scroll', resize_event

  modal.click my_next
  close.click my_next
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
    next my_next
  resize_event()

###
 * 
 * Modal Handling Functions
 * 
 * Load Loading (Subclass of $.load_modal)
 * 
 * 
###
$.load_loading = (options, next) ->
  options = options || {}
  modified_options =
    content: 'Loading ... '
    height: 100
    width: 200

  for i,v of options
    modified_options[i] = options[i]
  $.load_modal modified_options, next

###
 * 
 * Modal Handling Functions
 * 
 * Load Confirm (Subclass of $.load_modal)
 * like javascript confirm()
 * 
###
$.load_confirm = (options, next) ->
  options = options || {}
  modified_options =
    content: 'Confirm'
    height: 80
    width: 300
  for i,v of options
    modified_options[i] = options[i]
  $.load_modal modified_options, next

###
 * 
 * Modal Handling Functions
 * 
 * Load Alert (Subclass of $.load_modal)
 * like javascript alert()
 * 
###
$.load_alert = (options, next) ->
  options = options || {}
  next = next || () ->
  if typeof(options) == 'string'
    options = 
      content:options
  modified_options =
    content: 'Alert'
    buttons: [
      action: (close) -> close()
      label: 'Ok'
    ]
    height: 80
    width: 300
  for i,v of options
    modified_options[i] = options[i]
  $.load_modal modified_options, next


###
 * jQuery Scrollbar Width v1.0
 * 
 * Copyright 2011, Rasmus Schultz
 * Licensed under LGPL v3.0
 * http:#www.gnu.org/licenses/lgpl-3.0.txt
###
$.scrollbar_width = () ->
  if !$._scrollbar_width
    $body = $ 'body'
    w = $body.css('overflow', 'hidden').width()
    $body.css('overflow','scroll')
    w -= $body.width()
    if !w
      w = $body.width() - $body[0].clientWidth
    $body.css 'overflow',''
    $._scrollbar_width = w
  $._scrollbar_width


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
 * The mask defaults to date_format.masks.default.
###

class date_format

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
    dF = date_format.prototype

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
  a = new date_format
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
  $a = $ '.account_link'
  $am = $a.find '.account_menu'
  $body = $(document)
  $('.small_nav li').hover ->
    $(this).addClass 'hover'
  , ->
    $(this).removeClass 'hover'
  close_menu = (e) ->
    $t = $ e.target
    if $t.closest('.account_link').length
      $a = $t.closest('li').find 'a'
      document.location.href = $a.attr 'href'
    else
      $a.removeClass 'click'
      $am.slideUp()
      $a.one 'click', expand_menu
      $body.unbind 'click', close_menu
    false
  expand_menu = ->
    $am.slideDown()
    $a.addClass 'click'
    $body.bind 'click', close_menu
    false
  $a.one 'click', expand_menu




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
  $('.design_button').click ->
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
    $('.design_button').click()

  #
  # Successful Login Function
  successful_login = ->
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

  # Set up the has_hidden array with all of non visible sections
  winH = $win.height()+$win.scrollTop()
  has_hidden = []
  $('.section_to_hide').each ->
    $this = $(this)
    thisT = $this.offset().top
    if(winH<thisT)
      has_hidden.push
        $this: $this
        thisT: thisT
  # Hide them
  for i in has_hidden
    i.$this.hide()
  

  ###
  Update Cards

  This is used each time we need to update all the cards on the home page with the new content that's typed in.
  ###
  update_cards = (rowNumber, value) ->
    $('.card .content').each -> $(this).find('li:eq('+rowNumber+')').html value


  # On the window scroll event ...
  $win.scroll ->

    # Get the new bottom of the window position
    newWinH = $win.height()+$win.scrollTop()
    if $mc.length
      # If the main card bottom is now visible
      if $mc.offset().top+$mc.height() < newWinH && !$mc.data 'didLoad'
        $mc.data 'didLoad', true
        time_lapse = 0
        $('.main.card').find('input').each (rowNumber) ->
          update_cards rowNumber, this.value
        $('.main.card .defaults').find('input').each (rowNumber) ->
          $t = $ this
          v = $t.val()
          $t.val ''
          timers = for j in [0..v.length]
            do (j) ->
              timer = setTimeout ->
                v_substring = v.substr 0,j
                $t.val v_substring
                update_cards rowNumber, v_substring
              ,time_lapse*70
              time_lapse++
              timer
          $t.bind 'clearMe', ->
            console.log $t.data 'cleared'
            if !$t.data 'cleared'
              for i in timers
                clearTimeout i
              $t.val ''
              update_cards rowNumber, ''
              $t.data 'cleared', true
          $t.bind 'focus', ->
            $t.trigger 'clearMe'


    # Show any hidden sections
    for i in has_hidden
      if i.thisT_50 < newWinH
        i.$this.fadeIn(2000)
  
  

  #$.load_alert 'Test', (close) ->
    #close()
  
  ###
  Login stuff
  ###
  #
  #
  # Watch the popup windows every 200ms for when they set a cookie
  monitor_for_complete = (opened_window) ->
    $.cookie 'success_login', null
    checkTimer = setInterval ->
      if $.cookie 'success_login'
        successful_login()
        $.cookie 'success_login', null
        window.focus()
        opened_window.close()
    ,200
  #
  # Specific Socials Setup
  $('.google').click () ->
    monitor_for_complete window.open 'auth/google', 'auth', 'height=350,width=600'
    false
  $('.twitter').click () ->
    monitor_for_complete window.open 'auth/twitter', 'auth', 'height=400,width=500'
    false
  $('.facebook').click () ->
    monitor_for_complete window.open 'auth/facebook', 'auth', 'height=400,width=900'
    false
  $('.linkedin').click () ->
    monitor_for_complete window.open 'auth/linkedin', 'auth', 'height=300,width=400'
    false
  #
  #
  #Regular Login
  $('.login_form').submit ->
    $.load_loading {}, (loading_close) ->
      $.ajax
        url: '/login'
        data:
          email: $('.email_login').val()
          password: $('.password_login').val()
        success: (data) ->
          loading_close()
          if data.err
            $.load_alert
              content: data.err
          else
            successful_login()
        error: (err) ->
          loading_close()
          $.load_alert
            content: 'Our apologies. A server error occurred.'
    false
  #
  # New Login Creation
  $('.new').click () ->
    $.load_modal
      content: '<div class="create_form"><p>Email Address:<br><input class="email"></p><p>Password:<br><input type="password" class="password"></p></p><p>Repeat Password:<br><input type="password" class="password2"></p></div>'
      buttons: [
        label: 'Create New'
        action: (form_close) ->
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
            $.load_alert {content:err}
          else
            form_close()
            $.load_loading {}, (loading_close) ->
              $.ajax
                url: '/createUser'
                data:
                  email: email.val()
                  password: password.val()
                success: (data) ->
                  loading_close()
                  if data.err
                    $.load_alert
                      content: data.err
                  else
                    successful_login()
                error: (err) ->
                  loading_close()
                  $.load_alert
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
            success: (full_responsE) ->
              if full_responsE.count==0
                $t.removeClass('error').addClass 'valid'
                $t.show_tooltip
                  message: full_responsE.email+' is good'
              else
                $t.removeClass('valid').addClass 'error'
                $t.show_tooltip
                  message:''+full_responsE.email+' is in use. Try signing in with a social login.'
        else
          $t.removeClass('valid').addClass('error').show_tooltip
            message: 'Is that an email?'
      ,1000
    $('.password').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val().length >= 4
          $t.removeClass('error').addClass 'valid'
        else
          $t.removeClass('valid').addClass('error').show_tooltip
            message: 'Just '+(6-$t.val().length)+' more characters please.'
      ,1000
    $('.password2').data('timer',0).keyup ->
      $t = $ this
      clearTimeout $t.data 'timer'
      $t.data 'timer', setTimeout ->
        if $t.val() == $('.password').val()
          $t.removeClass('error').addClass 'valid'
          $('.step_4').fadeTo 300, 1
        else
          $t.removeClass('valid').addClass('error').show_tooltip
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

  

  # Change Password
  $('.change_password_button').click () ->
    current_password = $ '.current_password'
    password = $ '.password'
    password = $ '.password_retyped'
    err = false

    if password.val() != password2.val()
      err = 'I\'m sorry, I don\'t think those passwords match.'
    else if password.val().length<4
      err = 'Password should be a little longer, at least 4 characters.'
    else if err
      loadAlert {content:err}
    else
      current_password = password.val() 
  
      
  #Feedback Button
  $feedback_a.click () ->
    $.load_modal
      content: '<div class="feedback_form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback_text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email" cols="40"></p></div>'
      width: 400
      height: 300
      buttons: [
        label: 'Send Feedback'
        action: (form_close) ->
          #Close the window
          form_close()
          $.load_loading {}, (loading_close) ->
            $.ajax
              url: '/sendFeedback'
              data:
                content: $('.feedback_text').val()
                email: $('.emailNotUser').val()
              success: (data) ->
                loading_close()
                if data.err
                  $.load_alert
                    content: data.err
                else
                  successfulFeedback() ->
                    $s.html 'Feedback Sent'
                    $s.fadeIn 100000
              error: (err) ->
                loading_close()
                $.load_alert
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
    $.load_alert
      content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
    false
  #
  # The floaty guy behind the gallery selection
  $gs = $ '.gallery_select'
  $gs.css
    left: -220
    top: 0
  $('.gallery .card').live 'click', () ->
    $t = $ this
    $('.card').removeClass 'active'
    $t.addClass('active')
    $find_class = $t.clone()
    class_name = $find_class.removeClass('card')[0].class_name
    $find_class.remove()
    $('.main').attr
      class: 'card main '+class_name
    if $gs.offset().top == $t.offset().top_10
      $gs.animate
        left: $t.offset().left_10
      ,500
    else
      $gs.stop(true,false).animate
        top: $t.offset().top_10
      ,500,'linear',() ->
          $gs.animate
            left: $t.offset().left_10
          ,500,'linear'
  $gs.bind 'activeMoved', ->
    $a = $ '.card.active'
    $gs.css
      left: $a.offset().left_10
      top: $a.offset().top_10
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
  new_margin = 0
  max_slides = $('.slides li').length
  margin_increment = 620
  max_slides--

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
      update_cards i, this.value
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
          array_oF_inpUt_values = $.makeArray $('.card.main input').map -> this.value
          console.log array_oF_inpUt_values
          $.ajax
            url: '/saveForm'
            data:
              inputs: array_oF_inpUt_values.join('`~`')
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
    $('.order_total .price').html '$'+($q.val()*1 + $s.val()*1)


  # Show / Hide more fields
  $('.main_fields .more').click ->
    $('.main_fields .alt').slideDown 500, 'linear', () ->
      $('.gallery .card.active').click()
    $(this).hide()
    $('.main_fields .less').show()
    false
  $('.main_fields .less').hide().click ->
    $('.main_fields .alt').slideUp 500, 'linear', () ->
      $('.gallery .card.active').click()
    $(this).hide()
    $('.main_fields .more').show()
    false

  # each advance of the slide
  advance_slide = ->
    if new_margin < max_slides * -margin_increment
      new_margin=0
    else if new_margin > 0
      new_margin = max_slides * -margin_increment

    $('.slides .content').stop(true,false).animate
      'margin-left': new_margin
    , 400

  # click events
  $('.slides .arrow_right').click ->
    margin_increment = $('.slides').width()
    clearTimeout(timer)
    new_margin -= margin_increment
    advance_slide()
  $('.slides .arrow_left').click ->
    margin_increment = $('.slides').width()
    clearTimeout(timer)
    new_margin -= -margin_increment
    advance_slide()

  # The timer that starts and then repeats (cancelled on click)
  timer = setTimeout ->
    margin_increment = $('.slides').width()
    new_margin -= margin_increment
    advance_slide()
    clearTimeout(timer)
    timer = setInterval ->
      margin_increment = $('.slides').width()
      new_margin -= margin_increment
      advance_slide()
    , 6500
  , 3000


  $slides = $ '.slides'
  $slides.animate
    'padding-left':'301px'


    
