#= require 'libs/jquery-1.7.1.js'
#= require 'libs/date'
#= require 'libs/qrcode'
#= require 'libs/scrollTo.js'
#= require 'libs/underscore.js'
#= require 'libs/jquery-ui-1.8.16.js'
#= require 'libs/jquery.colorpicker.js'
#= require 'libs/socket.io.js'


##################################################################
#
###

This file is everywhere on the site

- We put a lot of library functions in it
- As well as things that need to happen on every page

###
#
##################################################################








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
  contentType: 'application/json'
$window = $ window 
if $.browser.msie and parseInt($.browser.version, 10)<9
  $.fx.speeds._default = 0
else
  $.fx.speeds._default = 300
#
#
#
#
$.line_copy = [
  'John Stamos'
  'Uncle Jesse'
  'Monkey.com'
  '123-456-7890'
  ''
  ''
  ''
  ''
  ''
  ''
]




#################################################################
#
#
# BEGIN Re-usable functions for everywhere
#
#
#
#
#
#
#
#
#
#
#
#
#
$.fn.qr = (options) ->
  settings = 
    color: '000000'
    height: 50
    width: 50
    url: 'cards.ly'
  this.each (i) ->
    if options
      $.extend settings, options
    $t = $(this)
    #
    #$t.prep_qr
    #  url: settings.url
    #
    #$t.draw_qr
    #  color: settings.color
    #
    #
    $canvas = $t.find('canvas')
    if not $canvas.length
      $canvas = $ '<canvas />'
      $t.append $canvas
    #
    #
    #
    #
    $.draw_qr
      $canvas: $canvas
      url: settings.url
      hex: settings.color
      hex_2: 'transparent'
    $t.css
      height: settings.height
      width: settings.width
    $t.find('canvas').css
      height: settings.height
      width: settings.width
    if typeof(G_vmlCanvasManager) isnt 'undefined'
      $t.find('canvas')[0].width = settings.width
      $t.find('canvas')[0].height = settings.height
      G_vmlCanvasManager.initElement($t.find('canvas')[0])
#
#
#
###
  * 
  *
  * Card Thumbnail Drawing Functions
  *
  *
###
#
#
#
#
# helper function to create styled card
$.create_card_from_theme = (options) ->
  settings =
    height: 90
    width: 158
    theme: null
    active_view: 0
  #
  if options
    $.extend settings, options
  
  #
  # Set Constants
  theme_template = settings.theme.theme_templates[settings.active_view] or settings.theme.theme_templates[0]
  #
  #
  # Prep the Card
  $my_card = $ '<div class="card"><img class="qr" /></div>'
  #
  $my_card.data 'theme', settings.theme
  #
  $my_qr = $my_card.find('.qr')
  #
  # Calculate the alpha
  alpha = Math.round(theme_template.qr.color2_alpha * 255).toString 16
  #
  #
  $my_qr.attr 'src', '/qr/'+theme_template.qr.color1+'/'+theme_template.qr.color2+alpha+'/'+(theme_template.qr.style or 'round')+''
  #
  $my_qr.css
    height: theme_template.qr.h/100 * settings.height
    width: theme_template.qr.w/100 * settings.width
    position: 'absolute'
    top: theme_template.qr.y/100 * settings.height
    left: theme_template.qr.x/100 * settings.width
    zIndex: 200
  #
  #
  #
  for pos,i in theme_template.lines
    $li = $ '<div class="line">' + $.line_copy[i] + '</div>'
    $li.appendTo($my_card).css
      position: 'absolute'
      top: pos.y/100 * settings.height
      left: pos.x/100 * settings.width
      width: (pos.w/100 * settings.width) + 'px'
      fontSize: (pos.h/100 * settings.height) + 'px'
      lineHeight: (pos.h/100 * settings.height) + 'px'
      fontFamily: pos.font_family
      textAlign: pos.text_align
      color: '#'+pos.color
  #
  #
  # Set the card background
  $my_card.css
    background: '#FFF url(\'//d3eo3eito2cquu.cloudfront.net/'+settings.width+'x'+settings.height+'/' + settings.theme.s3_id + '\')'
#
#
# another helper function to add it to a category
$.add_card_to_category = ($my_card, theme) ->
  $categories = $ '.categories'
  #
  # Find an existing category
  $category = $categories.find('.category[category="' + theme.category + '"]')
  #
  # If that category doesn't exist yet
  if $category.length == 0
    #
    # Create it
    $category = $ '<div class="category" category="' + theme.category + '"><h4>' + (theme.category||'(no category)') + '<div class="arrow_container"><div class="arrow"></div></div></h4><div class="cards"></div></div>'
    #
    # And add it to the categories list
    $categories.prepend $category
  #
  #
  # Finally add it
  $category.find('.cards').prepend $my_card
#
#
#
#
#
#
#
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
  modal = $ '<div class="modal" />'
  win = $ '<div class="window" />'
  close = $ '<div class="close" />'
  $body = $ document

  settings =
    width: 500
    height: 235
    closeText: 'close'

  if options
    $.extend settings, options


  $('iframe').css 'visibility', 'hidden'

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
      $('iframe').css 'visibility', ''
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
  #
  buttons = $ '<div class="buttons" />'
  #
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
      do (i) ->
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
#
#
#
#
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
#
#
#
#
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
#
#
#
#
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
#
#
#
#
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
#
#
#
#
#
#
#
#
#
#
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
      if options.path then '; path=' + options.path else '; path=/',
      if options.domain then '; domain=' + options.domain else '',
      if options.secure then '; secure' else ''
    ].join('')

  # key and possibly options given, get cookie...
  options = value || {}
  decode =  if options.raw  then (s) ->  s  else decodeURIComponent
  regex = '(?:^|; )' + encodeURIComponent(key) + '=([^;]*)'
  if (result = new RegExp(regex).exec(document.cookie)) then decode(result[1]) else null
#
#
#
#
#
# END Re-usable functions for everywhere
#
#
#################################################################




###
The 
$ ->

  Means everything under him (like me, indented here)
  WILL be done on document ready event.
###
#
#
#
#
$ ->
  #
  #
  $window = $window
  $document = $ document
  #
  #
  $('li,.title').hover ->
    $(this).addClass 'hover'
  , ->
    $(this).removeClass 'hover'
  #
  #
  logged_in = ->
    $.ajax
      url: '/get-user'
      success: (result) ->
        if not result.err
          console.log result
          user = result.user

          if $home_designer.length
            $phone = $home_designer.find '.phone'
            $profile_image = $phone.find '.profile_image'
            if user.profile_image_url
              #
              #
              profile_image_index = _(user.profile_image_urls).indexOf user.profile_image_url
              #
              $new_image = $ '<img class="profile_image" />'
              $new_image.attr 'src', user.profile_image_url
              $new_image.click ->
                #
                profile_image_index++
                profile_image_index = 0 if profile_image_index >= user.profile_image_urls.length
                #
                $new_image.attr 'src', user.profile_image_urls[profile_image_index]
                #
              #
              $profile_image.replaceWith $new_image

  #
  #
  logged_in()
  #
  #
  # Watch the popup windows every 200ms for when they set a cookie
  monitor_for_complete = (opened_window) ->
    $.cookie 'success_login', null
    checkTimer = setInterval ->
      if $.cookie 'success_login'
        $.cookie 'success_login', null
        window.focus()
        opened_window.close()
        #
        #
        #
        # DO MORE HERE
        logged_in()
        #
        #
        #
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
  #
  #
  #
  #
  ctrl_pressed = false
  shift_pressed = false
  # Prevent Backspace

  $body = $ document
  $body.keydown (e) ->
    if e.keyCode is 8
      $t = $ e.target
      if not $t.closest('input').andSelf().filter('input').length
        if not $t.closest('textarea').andSelf().filter('textarea').length
          e.preventDefault()
    #
    # Modify the amount we shift when the shift key is pressed
    if e.keyCode is 16
      shift_pressed = true
    #
    # Ctrl or Command Pressed Down
    if e.keyCode is 17 or e.keyCode is 91 or e.keyCode is 93
      ctrl_pressed = true
    #
    #
    # Undo 
    if ctrl_pressed and not shift_pressed and e.keyCode is 90
      e.preventDefault()
      console.log 'undo'
    #
    # Redo
    if ctrl_pressed and shift_pressed and e.keyCode is 90
      e.preventDefault()
      console.log 'redo'
    #
  $body.keyup (e) ->
    if e.keyCode is 17 or e.keyCode is 91 or e.keyCode is 93
      ctrl_pressed = false
    if e.keyCode is 16
      shift_pressed = false
  #
  #
  #
  #
  #
  #
  #
  #
  #
  $pull_down = $ '.pull_down'
  #
  #

  #
  #
  detect_pull_start = (e) ->
    unless $pull_down.data 'active'
      o = [e.offsetX,e.offsetY]
      if o[1] < 480 or (o[0] > 90 and o[0] < 132)
        $pull_down.unbind 'mousemove', detect_pull_start
        $pull_down.stop(true,false).animate
          marginTop: 10
        , 200
        $pull_down.one 'mouseout', ->
          unless $pull_down.data 'active'
            $pull_down.stop(true,false).animate
              marginTop: 0
            , 200
  #
  #
  $pull_down.bind 'mouseover', (e) ->
    $pull_down.bind 'mousemove', detect_pull_start
    detect_pull_start e
  $pull_down.bind 'mouseout', (e) ->
    $pull_down.unbind 'mousemove', detect_pull_start
  #
  #
  $pull_down.bind 'click', (e) ->
    unless $pull_down.data 'active'
      $pull_down.stop(true,false).animate
        marginTop: 590
      , 400
      $pull_down.data 'active', true
      setTimeout ->
        $body.one 'click', ->
          $pull_down.stop(true,false).animate
            marginTop: 0
          , 200
          $pull_down.data 'active', false
      , 0
      
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  $home_designer = $ '.home_designer'
  #
  if $home_designer.length
    #
    #
    #
    #
    #
    #
    # Scroll the card preview
    #
    $card = $home_designer.find '.card'
    c_o = $card.offset()
    $card.css
      'position' : 'absolute'
      'top' : c_o.top
    $window.scroll ->
      b_t = $body.scrollTop()
      if c_o.top < b_t
        $card.css
          'position' : 'fixed'
          'top' : 0
      else
        $card.css
          'position' : 'absolute'
          'top' : c_o.top
    #
    #
    #
    #
    #
    #
    #
    #
    #
    #
    $areas = $home_designer.find '.area'
    #
    #
    $titles = $home_designer.find '.title'
    $titles.each (title_index) ->
      $title = $ this
      $title.click ->
        #
        #
        $titles.removeClass 'active'
        $areas.removeClass 'active'
        #
        #
        $area = $areas.eq title_index
        #
        $area.addClass 'active'
        $title.addClass 'active'
        #
        $area.html ''
        #
        #
        if $title.html() is 'Text'
          for i in [1..6]
            $area.append '<input />'
    #
    #
    $titles.eq(0).click()
    #
    #
    #
    #
    #
    $themes = $home_designer.find '.themes'
    $thumbs = undefined
    #
    #
    $.ajax
      url: '/get-themes'
      success: (all_data) ->
        #
        #
        for theme,i in all_data.themes
          #
          $new_image = $ '<img />'
          $new_image.attr
            src: '/thumb/'+theme._id
            id: theme._id
          #
          #
          $themes.append $new_image
          #
        #
        $thumbs = $themes.find 'img'
        #
        $thumbs.hover ->
          $(this).addClass 'hover'
        , ->
          $(this).removeClass 'hover'
        #
        $thumbs.click ->
          #
          $thumb = $ this
          id = $thumb.attr 'id'
          #
          $thumbs.removeClass 'active'
          $thumb.addClass 'active'
          #
          #
          console.log id
        #
        #
        $thumbs.eq(0).click()
      #
      #
      error: ->
        $.load_alert
          content: 'Error loading themes. Please try again later.'
    #
    #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  socket = io.connect()
  socket.on 'connect', () ->
    socket.on 'load-session', (session) ->
      console.log session
  #
  #
  #
  #
  #
  #
  ###
  DNode.connect (remote) ->
    remote.get_history 'log_home', (result) ->
      console.log result
  ###
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #