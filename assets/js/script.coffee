#= require 'libs/jquery-1.7.1.js'
#= require 'libs/date'
#= require 'libs/qrcode'
#= require 'libs/scrollTo.js'
#= require 'libs/underscore.js'
#= require 'libs/jquery-ui-1.8.16.js'
#= require 'libs/jquery.colorpicker.js'
#= require 'libs/socket.io.js'
#= require 'libs/jquery.lettering.js'
#= require 'libs/luhn.js'


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
  'Harold Crick'
  '123 Fiction St'
  'Phoenix, AZ 85204'
  '555-555-5545'
  'email@gmail.com'
  '@numberman'
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
$.fn.make_active = (options) ->
  this.each (i) ->
    $t = $(this)
    $t.siblings().removeClass 'active'
    $t.addClass 'active'
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
    units: 'px'
    theme: null
    active_view: 0
    card: null
    side: 0
    card_number: 1
    url: 'cards.ly'
  #
  if options
    $.extend settings, options
  
  #
  #
  #
  # Prep the Card
  if settings.card
    $my_cards = settings.card
  else
    $my_cards = $ '<div class="card"></div>'
  #
  #
  #
  #
  #
  #
  #
  #
  $my_cards.each ->
    #
    #
    $my_card = $ this
    #
    #
    #
    $my_card.data 'theme', settings.theme
    theme = settings.theme
    #
    stylify_a_line = ($li, n_l, c_w, pos) ->
      #
      #
      $li.show().css
        position: 'absolute'
        top: pos.y/100 * settings.height + settings.units
        left: n_l + settings.units
        width: c_w + settings.units
        height: (pos.h/100 * settings.height) + settings.units
        fontSize: (pos.h/100 * settings.height) + settings.units
        lineHeight: (pos.h/100 * settings.height) + settings.units
        fontFamily: pos.font_family
        textAlign: pos.text_align
        whiteSpace: 'nowrap'
        color: '#'+pos.color
      #
      #console.log pos.color#
      #
      if $li.is ':visible'
        #
        t_a = pos.text_align
        #
        $li.css
          width: 'auto'
        #
        n_w = $li.width()
        if t_a is 'right'
          n_l = n_l + c_w - n_w
        if t_a is 'center'
          n_l = n_l + (c_w - n_w)/2
        #
        $li.css
          left: n_l + settings.units
          width: n_w + settings.units
    #
    # ----------------------------------------------
    # Images
    # ----------------------------------------------
    widthheight = settings.width+'x'+settings.height
    widthheight = 'raw' if settings.width > 525
    widthheight = '158x90' if settings.width < 158
    widthheight = '525x300' if settings.width > 158 and settings.width < 525
    widthheight = 'raw' if settings.width is 3.5
    #
    #
    $imgs = $my_card.find '.img'
    $lines = $my_card.find '.line'
    $my_qr = $my_card.find('.qr')
    #
    #
    #
    $imgs.hide()
    $lines.hide()
    $my_qr.hide()
    img_i = 0
    line_i = 0
    qr_i = 0
    #
    #
    #
    #
    #
    #
    #
    #
    for item in theme.items
      #
      if settings.side is item.side
        #
        if item.type is 'image'
          if $imgs.eq(img_i).length
            $img = $imgs.eq(img_i)
          else
            #
            $img = $ '<div class="img"><img /><div class="color" /></div>'
            #
            $img.appendTo $my_card
            #
          if item.s3_id
            #
            $img.find('.color').hide()
            $img.find('img').show().attr 'src', '//d3eo3eito2cquu.cloudfront.net/'+widthheight+'/'+item.s3_id
            #
          else if item.color
            #
            $img.find('img').hide()
            $img.find('.color').show().css 'background-color', '#'+item.color
            #
          $img.show().css
            position: 'absolute'
            top: item.y/100 * settings.height + settings.units
            left: item.x/100 * settings.width + settings.units
            width: (item.w/100 * settings.width) + settings.units
            height: (item.h/100 * settings.height) + settings.units
          #
          img_i++
        #
        #
        #
        if item.type is 'qr'
          #
          if not $my_qr.length
            $my_qr = $ '<img class="qr" />'
            $my_card.append $my_qr
          #
          alpha = Math.round(item.color_2_opacity * 255).toString 16
          #
          $my_qr.attr 'src', '/qr/'+item.color+'/'+item.color_2+alpha+'/'+(item.style or 'round')+'/'+settings.card_number+'?'+settings.url
          #
          $my_qr.show().css
            height: item.h/100 * settings.height + settings.units
            width: item.w/100 * settings.width + settings.units
            position: 'absolute'
            top: item.y/100 * settings.height + settings.units
            left: item.x/100 * settings.width + settings.units
          #
          #
          qr_i++
        #
        #
        #
        #
        #
        #
        if item.type is 'line'
          $li = $lines.eq line_i
          n_l = item.x/100 * settings.width
          c_w = item.w/100 * settings.width
          #
          #
          do ($li, n_l, c_w, item, line_i) ->
            #
            if not $li.length
              #
              $li = $ '<div class="line" />'
              $li.appendTo $my_card
              #
              $li.html $.line_copy[line_i]
              setTimeout ->
                stylify_a_line($li, n_l, c_w, item)
              , 500
              #
            else
              $li.html $.line_copy[line_i]
              stylify_a_line $li, n_l, c_w, item
            #
          #
          line_i++
    #
    #
    # ----------------------------------------------
    # END Images
    # ----------------------------------------------
    #
    #
    #
    #
    #
    #
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
  #
  #
  #
  # Watch the popup windows every 200ms for when they set a cookie
  monitor_for_complete = (e, opened_window) ->
    $.cookie 'success_login', null
    checkTimer = setInterval ->
      if $.cookie 'success_login'
        $.cookie 'success_login', null
        window.focus()
        opened_window.close()
        #
        #
        #
        #
        $target = $ e.target
        #
        #
        if $target.closest('.navigation').length
          #
          document.location.href = '/cards'
          #
        else
          $.load_loading {}, (loading_close) ->
            $.ajax
              url: '/get-user'
              success: (response) ->
                loading_close()
                if response.err
                  $.load_alert
                    content: response.err
                else
                  #
                  new_url = false
                  for url in response.user.profile_urls
                    $('.set_link').val(url).keyup()
                    new_url = url
                  #
                  content = '<p>Connected. Login again anytime using that same button.</p>'
                  if new_url
                    content += '<p>&nbsp;</p><p>Your cardsly cards now link to:</p><p><a href="'+new_url+'">'+new_url+'</a></p><p>You may change this at anytime.</p>'
                  #
                  $.load_alert
                    width: 500
                    height: 400
                    content: content
                  #
                  #
                  $('.navigation .login .trigger a').remove()

                #
                #
              error: (err) ->
                loading_close()
                $.load_alert
                  content: 'Our apologies. A server error occurred.'
        #
        #
        #
    ,200
  #
  # Specific Socials Setup
  $('.google').click (e) ->
    monitor_for_complete window.open 'auth/google', 'auth', 'height=350,width=600'
    false
  $('.twitter').click (e) ->
    monitor_for_complete e, window.open 'auth/twitter', 'auth', 'height=400,width=500'
    false
  $('.facebook').click (e) ->
    monitor_for_complete e, window.open 'auth/facebook', 'auth', 'height=400,width=900'
    false
  $('.linkedin').click (e) ->
    monitor_for_complete e, window.open 'auth/linkedin', 'auth', 'height=300,width=400'
    false
  #
  #
  #
  #
  #
  #
  #
  if typeof(window.orientation) isnt 'undefined'
    check_orient = ->
      if window.orientation is 0 or window.orientation is 180
        w = screen.width
        $('meta[name=viewport]').attr 'content', 'width=569, initial-scale='+(w/569)+', user-scalable=no'
      else
        h = screen.height
        $('meta[name=viewport]').attr 'content', 'width=1024, initial-scale='+(h/1024)+', user-scalable=yes'
    window.onorientationchange = check_orient
    check_orient()
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
  ctrl_pressed = false
  shift_pressed = false
  $window.blur ->
    shift_pressed = false
    ctrl_pressed = false
  #
  $body = $ document
  $body.keydown (e) ->
    k = e.keyCode
    #
    #
    # Prevent Backspace
    if k is 8
      $t = $ e.target
      if not $t.closest('input').andSelf().filter('input').length
        if not $t.closest('textarea').andSelf().filter('textarea').length
          e.preventDefault()
          #
          # Also, allow backspace to delete stuff in the editor
          $active_items = $editor.find '.active'
          $active_items.each ->
            $active_item = $ this
            $close_button = $active_item.data '$close_button'
            if $close_button and $close_button.length
              $close_button.click()
    #
    # Modify the amount we shift when the shift key is pressed
    if k is 16
      shift_pressed = true
    #
    # Ctrl or Command Pressed Down
    if k is 17 or k is 91 or k is 93
      ctrl_pressed = true
    #
    #
    # Undo 
    if ctrl_pressed and not shift_pressed and k is 90
      e.preventDefault()
      #console.log 'undo'
    #
    # Redo
    if ctrl_pressed and shift_pressed and k is 90
      e.preventDefault()
      #console.log 'redo'
    #
    #
    #
    # Up and Down
    if k is 38 or k is 40 or k is 37 or k is 39
      $t = $ e.target
      #if not $t.closest('input').andSelf().filter('input').length
      if not $t.closest('textarea').andSelf().filter('textarea').length
        if not $t.closest('select').andSelf().filter('select').length
          # Also, allow backspace to delete stuff in the editor
          $active_items = $editor.find '.active'
          $active_items.each ->
            e.preventDefault()
            $active_item = $ this
            #
            #
            position = $active_item.position()
            width = $active_item.width()
            height = $active_item.height()
            #
            n_l = position.left
            n_t = position.top
            #
            to_shift = 2
            #
            to_shift = 10 if shift_pressed
            #
            if k is 38
              n_t = n_t - to_shift
            if k is 40
              n_t = n_t + to_shift
            if k is 37
              n_l = n_l - to_shift
            if k is 39
              n_l = n_l + to_shift
            #
            n_l = min_l if n_l < min_l
            n_t = min_t if n_t < min_t
            #
            n_l = max_l-width if n_l+width > max_l
            n_t = max_t-height if n_t+height > max_t
            #
            $active_item.css
              left: n_l
              top: n_t
            #
            #
            move_my_buttons n_l, width, n_t, height, $active_item
          #
    #
    #
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
  ##################################################################
  #
  # Dropdown Menu
  #
  #
  #
  $login = $ '.navigation .login'
  $trigger = $login.find '.trigger'
  $dropdown = $login.find '.dropdown'
  $trigger.click (e) ->
    #
    e.preventDefault()
    #
    close_menu = (e) ->
      #
      $target = $ e.target
      #
      unless $target.closest('.navigation,.window,.modal').length
        #
        $dropdown.slideUp 150
        $dropdown.removeClass 'active'
        #
        $body.unbind 'click', close_menu
      #
    expand_menu = (e) ->
      $dropdown.slideDown 150
      $dropdown.removeClass 'active'
      #
      #
    #
    unless $dropdown.hasClass 'active'
      #
      expand_menu e
      #
      #
      $body.bind 'click', close_menu


  #
  #
  # END MENU
  #
  #################################################################
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
  active_theme = {}
  #
  $home_designer = $ '.home_designer'
  #
  if $home_designer.length
    #
    #
    order = {}
    #
    #
    #s
    order.active_theme_id = '4ec3fb7b3bf1fc0100000042'
    #
    #
    $all_card = $ '.card'
    #
    $card = $all_card.filter ':not(.preview_2)'
    #
    #
    #
    $editor = $all_card.filter '.editor'
    #
    max_t = $editor.outerHeight()
    min_t = 0
    min_l = 0
    max_l = $editor.outerWidth()
    #
    #
    #
    $design_now = $ '.design_now'
    #
    $design_now.click ->
      $body.scrollTo $home_designer,
        offset:
          left: 0
          top: 28
        duration: 500
      false
    #
    #
    #
    #
    $rows = $ '.row'
    $help_overlays = $rows.find '.help_overlay'
    $help_bg = $help_overlays.find '.button_hide, .bg, .dialog'
    $help_show = $help_overlays.find '.button_show'
    #
    help_visible = true
    $help_overlays.each ->
      $h_o = $ this
      #
      if document.location.href.match '/settings'
        $help_bg.hide()
        $help_show.show()
        $help_overlays.removeClass 'active'
        help_visible = false
        #
      #
      $h_o.click (e) ->
        #
        if help_visible
          $help_bg.hide()
          $help_show.show()
          $help_overlays.removeClass 'active'
          help_visible = false
          #
          $e = $ e.target
          if $e.closest('.row').hasClass 'home_designer'
            setTimeout ->
              $editor.find('.line:first').addClass 'active'
              new_active()
              add_remove_focus_event()
            , 0
          #
        else
          $help_bg.show()
          $help_show.hide()
          $help_overlays.addClass 'active'
          help_visible = true
          
    #
    #
    #
    #
    #
    #
    $areas = $home_designer.find '.area'
    #
    #
    #
    $upload_button = $home_designer.find '.upload_button'
    $upload_form = $home_designer.find '.upload_form'
    $upload_input = $upload_form.find 'input[type=file]'
    #
    #
    #
    $upload_button.unbind('click').click -> $upload_input.click()
    re_bind_change_event = ->
      #
      $new_upload_input = $ '<input type="file" name="image" />'
      #
      $upload_input.replaceWith $new_upload_input
      #
      $upload_input = $new_upload_input
      #
      $upload_input.unbind('change').change -> 
        #
        $.load_loading {}, (loading_close) ->
          $upload_form.submit()
          $.s3_result = (response) ->
            loading_close()
            if response and response.s3_id
              $active_image = $editor.find '.active.img'
              $active_image.find('.color').hide()
              $active_image.find('img').show().attr 'src', '//d3eo3eito2cquu.cloudfront.net/525x300/'+response.s3_id
              $active_image.width response.width / 2
              $active_image.height response.height / 2
              new_active()
              theme_modified()
            else
              $.load_alert
                content: '<p>I\'m sorry, I had trouble processing that specific image.</p>'
            #
            re_bind_change_event()
        #
    re_bind_change_event()
    #
    #
    #
    $themes = $home_designer.find '.themes'
    $thumbs = undefined
    #
    $notify_form = $ '.notify_form'
    #
    $link_items = $notify_form.find '.link_items'
    #
    $show_themes = $home_designer.find '.show_themes'
    #
    $font_families = $areas.find '.font_families'
    $font_size = $areas.find '.font_size'
    #
    #
    # ---------
    # Thumbs
    # ------------------------------------
    #
    $text_align = $home_designer.find '.text_align .option'
    #
    $qr_style = $home_designer.find '.qr_style .option'
    #
    $color_2_opacity = $home_designer.find '.color_2_opacity'
    #
    $ours_yours = $home_designer.find '.ours_yours'
    #
    $my_themes = $home_designer.find '.my_themes'
    #
    #
    theme_modified_timer = 0
    #
    get_hex_color = (in_color) ->
      if in_color.match /rgb/
        digits = in_color.match /\((\d+), (\d+), (\d+)(\)|,)/
        if digits
          in_color = rgb_to_hex digits[1], digits[2], digits[3]
      #
      #
      in_color.replace /#/, ''
    #
    rgb_to_hex = (r, g, b) -> to_hex(r)+to_hex(g)+to_hex(b)
    to_hex = (n) ->
      n = parseInt n, 10
      if isNaN n 
        return '00'
      n = Math.max 0, Math.min n, 255
      "0123456789ABCDEF".charAt((n-n%16)/16)+ "0123456789ABCDEF".charAt(n%16)
    #
    #
    #
    #
    #
    #
    update_preview_with_active = ->
      ###

      This updating of the preview card

      ###
      side = 0
      if $front_back.filter('.active').html().toLowerCase() is 'back'
        side = 1
      #
      $all_card.filter('.preview').each ->
        #
        $this_card = $ this
        #
        $fg = $this_card.find '.fg'
        if not $fg.length
          $fg = $ '<div class="fg" />'
          $fg.addClass 'collapsed2' if side is 'back'
          $fg.hide() if side is 'back'
          $this_card.append $fg
        #
        $bg = $this_card.find '.bg'
        if not $bg.length
          $bg = $ '<div class="bg" />'
          $bg.addClass 'collapsed2' if side is 'front'
          $bg.hide() if side is 'front'
          $this_card.append $bg
        #
        #
        $.create_card_from_theme
          height: 300
          width: 525
          theme: active_theme
          active_view: 0
          card: $fg
          side: 0
        #
        $.create_card_from_theme
          height: 300
          width: 525
          theme: active_theme
          active_view: 0
          card: $bg
          side: 1
    #
    #
    #
    #
    #
    #
    actually_save_active_theme = ->
      clearTimeout theme_modified_timer
      #
      theme_modified_timer = 0
      #
      #
      $visible_items = $editor.find '.fg:not(.collapsed2) :visible, .bg:not(.collapsed2) :visible'
      #
      side = 0
      if $front_back.filter('.active').html().toLowerCase() is 'back'
        side = 1
      #
      #console.log $visible_items.length, side
      #
      #
      active_theme.items = _(active_theme.items).filter (item) -> item.side isnt side
      #
      #
      #
      #
      $visible_items.each ->
        $visible_item = $ this
        #
        my_l = parseInt $visible_item.css 'left'
        my_t = parseInt $visible_item.css 'top'
        my_h = $visible_item.height()
        my_w =$visible_item.width()
        #
        item =
          side: side
          x: (my_l / max_l) * 100
          y: (my_t / max_t) * 100
          h: (my_h / max_t) * 100
          w: (my_w / max_l) * 100
        #
        #
        if $visible_item.hasClass 'qr'
          item.type = 'qr'
          src = $visible_item.attr 'src'
          attributes = src.split /\//
          attributes = _(attributes).compact()
          #
          item.color = attributes[1]
          item.style = attributes[3]
          #
          item.color_2 = attributes[2].substr 0, 6
          #
          item.color_2_opacity = parseInt(attributes[2].substr(6,2),16)/255
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
        if $visible_item.hasClass 'img'
          #
          item.type = 'image'
          #
          $color = $visible_item.find '.color:visible'
          $img = $visible_item.find 'img:visible'
          #
          if $img.length
            src = $img.attr 'src'
            item.s3_id = src.replace /.*\//g, ''
            item.color = null
          else if $color.length
            item.s3_id = null
            item.color = get_hex_color $color.css 'background-color'
          #
          #
          #

        #
        if $visible_item.hasClass 'line'
          item.type = 'line'
          item.color = get_hex_color $visible_item.css 'color'
          item.font_family = $visible_item.css 'font-family'
          item.text_align = $visible_item.css 'text-align'
        #
        #
        active_theme.items.push item
        #
      #
      order.values = $editor.find('.line').map ->
        this.innerHTML
      .get()
      $.line_copy = order.values
      #
      #console.log 'BEFORE SAVE:', active_theme.user_id
      #
      if active_theme.user_id or document.location.href.match /admin/i
        #
        #
        $.ajax
          url: '/save-theme'
          data: JSON.stringify active_theme
          success: (result) ->
            #
            #
            if result.theme
              #
              #
              active_theme = result.theme if active_theme._id is result.theme._id
              #
              theme = result.theme
              #
              $themes.find('.thumb[id='+theme._id+'] .fg').attr
                src: '/thumb/'+result.theme._id+'/0?'+Math.random()
              #
              $themes.find('.thumb[id='+theme._id+'] .bg').attr
                src: '/thumb/'+result.theme._id+'/1?'+Math.random()
              #
              #
              #
              update_preview_with_active()
              #
              $.ajax
                url: '/save-order'
                data: JSON.stringify order
        #
      else
        #
        active_theme._id = ''
        delete active_theme._id
        for item, i in active_theme.items
          delete active_theme.items[i]._id
        #
        #
        $ours_yours.show()
        #
        $.ajax
          url: '/save-theme'
          data: JSON.stringify active_theme
          success: (result) ->
            #
            #
            if result.theme
              #
              #
              active_theme = result.theme unless active_theme._id
              #
              #
              theme = result.theme
              #
              #
              $new_thumb = $ '<div class="thumb"></div>'
              $new_thumb.attr
                id: theme._id
              #
              $fg_image = $ '<img class="fg" />'
              $fg_image.attr
                src: '/thumb/'+theme._id+''
              $new_thumb.append $fg_image
              #
              #
              $bg_image = $ '<img class="bg collapsed2" />'
              $bg_image.hide()
              $bg_image.attr
                src: '/thumb/'+theme._id+'/1'
              $new_thumb.append $bg_image
              #
              #
              $my_themes.append $new_thumb
              #
              $themes.find('.thumb').removeClass 'active'
              $new_thumb.addClass 'active'
              #
              #
              #
              update_preview_with_active()
              #
              #
              order.active_theme_id = active_theme._id
              #
              # And save it
              $.ajax
                url: '/save-order'
                data: JSON.stringify order
      #
      #
      #
      #
      # Do the actual save of the theme.
    #
    theme_modified = ->
      clearTimeout theme_modified_timer
      theme_modified_timer = setTimeout ->
        actually_save_active_theme()
      , 3000
    #
    #
    #
    #
    remove_focus_event = (e) ->
      $t = $ e.target
      $c = $t.closest('.controls').andSelf().filter('.controls')
      $e = $t.closest('.card.editor').andSelf().filter('.card.editor')
      $w = $t.closest('.color-window-guy').andSelf().filter('.color-window-guy')
      $u = $t.closest('.upload_form')
      unless $c.length or $e.length or $w.length or $u.length
        $editor.find('.active').removeClass 'active'
        $body.unbind 'click', remove_focus_event
        new_active()
    #
    add_remove_focus_event = ->
      $body.bind 'click', remove_focus_event
    new_active = -> {}
    #
    #
    move_my_buttons = (n_l,n_w,n_t,n_h,$active_line) ->
      $close_button = $active_line.data '$close_button' 
      if $close_button
        #
        left = n_l + n_w - 8
        top = n_t - 12
        #
        $close_button.css
          top: top
          left: left
      #
      #
      $resize_button = $active_line.data '$resize_button' 
      if $resize_button
        #
        left = n_l + n_w - 8
        top = n_t + n_h - 8
        #
        $resize_button.css
          top: top
          left: left
      #
      theme_modified()
    #
    card_loaded = ->
      #
      new_active = (o) ->
        #
        $images = $editor.find '.img'
        $qr = $editor.find '.qr'
        $lines = $editor.find '.line'
        #
        o = {} if not o
        #
        $active_lines = $lines.filter '.active'
        $active_qr = $qr.filter '.active'
        $active_image = $images.filter '.active'
        #
        $line_values = $home_designer.find '.line_values'
        $line_values.children().remove()
        $line_values = $ ''
        #
        $show_themes.show()
        #
        #
        #
        #
        $editor.find('.close_button,.resize_button').remove()
        #
        $active_lines.add($active_image).add($active_qr).each (i) ->
          $active_line = $ this
          #
          #
          # Close Button
          $close_button = $ '<div class="close_button">x</div>'
          $editor.append $close_button
          top = parseInt $active_line.css 'top'
          left = parseInt $active_line.css 'left'
          #
          left = left + $active_line.width() - 8
          top = top - 12
          #
          $close_button.css
            top: top
            left: left
          #
          $close_button.click ->
            $close_button.remove()
            $active_line.remove()
            $editor.find('.resize_button').remove()
            #
            theme_modified()
            #
            #
            if $editor.find('.qr:visible').length then $add_qr.hide() else $add_qr.show()
            #
            #
          #
          $active_line.data '$close_button', $close_button
          #
        #
        #
        $active_image.add($active_qr).each (i) ->
          $active_line = $ this
          #
          # Resize Button
          $resize_button = $ '<div class="resize_button"><img src="/images/arrow2.png"></div>'
          $editor.append $resize_button
          top = parseInt $active_line.css 'top'
          left = parseInt $active_line.css 'left'
          #
          left = left + $active_line.width() - 8
          top = top + $active_line.height() - 8
          #
          $resize_button.css
            top: top
            left: left
          #
          $resize_button.mousedown (e) ->
            #
            e.preventDefault()
            #
            editor_offset = $editor.offset()
            #
            x = e.pageX
            y = e.pageY
            #
            l = x - editor_offset.left
            t = y - editor_offset.top
            #
            $color_or_img = $active_line.find 'img:visible,.color:visible'
            #
            #
            position = $active_line.data 'position'
            width = $active_line.width()
            height = $active_line.height()
            n_l = parseInt $active_line.css 'left'
            n_t = parseInt $active_line.css 'top'
            #
            max_h = max_t - n_t
            max_w = max_l - n_l
            #
            move_event = (e_2) ->
              x_2 = e_2.pageX
              y_2 = e_2.pageY
              #
              moved_x = x - x_2
              moved_y = y - y_2
              #
              #
              #
              if $color_or_img.length and $color_or_img.hasClass 'color'
                #
                # Resize any way you want
                to_change = moved_y
                #
                n_h = height - moved_y
                n_w = width - moved_x
                #
                n_h = max_h if n_h > max_h
                n_w = max_w if n_w > max_w
                #
              else
                #
                # Resize and maintain aspect ratio version
                to_change = moved_y
                #
                n_h = height - to_change
                n_w = n_h * width / height
                #
                if n_h > max_h
                  n_h = max_h
                  n_w = max_h * width / height
                if n_w > max_w
                  n_w = max_w
                  n_h = max_w * height / width
                #
                #
              ###
              n_l = min_l if n_l < min_l
              n_t = min_t if n_t < min_t
              #
              n_l = max_l-width if n_l+width > max_l
              n_t = max_t-height if n_t+height > max_t
              ###
              #
              #
              $active_line.css
                width: n_w
                height: n_h
              #
              move_my_buttons n_l, n_w, n_t, n_h, $active_line
              #
              e_2.preventDefault()
            #
            #
            $body.one 'mouseup', (e_3) ->
              e_3.preventDefault()
              $body.unbind 'mousemove', move_event
            #
            $body.unbind('mousemove').mousemove move_event
          #
          $active_line.data '$resize_button', $resize_button
        #
        #
        #
        #
        if $active_lines.length
          #
          #
          #
          #
          shorten_all_lines = ->
            #
            #
            #
            #
            #
            #
            $active_lines.each (i) ->
              $active_line = $ this
              #
              # Shorten the line width to fit the text
              c_w = $active_line.width()
              c_h = $active_line.height()
              n_l = parseInt $active_line.css 'left'
              n_t = parseInt $active_line.css 'top'
              t_a = $active_line.css 'text-align'
              #
              $active_line.css
                width: 'auto'
              #
              n_w = $active_line.width()
              if t_a is 'right'
                n_l = n_l + c_w - n_w
              if t_a is 'center'
                n_l = n_l + (c_w - n_w)/2
              #
              $active_line.css
                left: n_l
                width: n_w
              #
              move_my_buttons n_l, n_w, n_t, c_h, $active_line
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
          $active_lines.each (i) ->
            $active_line = $ this
            #
            $line_value = $line_values.eq i
            #
            unless $line_value.length
              $line_value = $ '<input class="line_value" />'
              $home_designer.find('.line_values').append $line_value
              $line_value.after '<div class="button save">Save</div><div class="clear" />'
            #
            $save_button = $line_value.next()
            #
            $save_button.hide()
            #
            $line_value.unbind('focus').focus ->
              $home_designer.find('.save.button').hide()
              $save_button.show()
            #
            $save_button.click -> $body.click()
            #
            $line_value.val $active_line.html()
            #
            #
            #
            # Shorten the line width to fit the text
            shorten_this_line = ->
              c_w = $active_line.width()
              n_l = parseInt $active_line.css 'left'
              c_h = $active_line.height()
              n_t = parseInt $active_line.css 'top'
              t_a = $active_line.css 'text-align'
              #
              $active_line.css
                width: 'auto'
              #
              n_w = $active_line.width()
              if t_a is 'right'
                n_l = n_l + c_w - n_w
              if t_a is 'center'
                n_l = n_l + (c_w - n_w)/2
              #
              $active_line.css
                left: n_l
                width: n_w
              #
              move_my_buttons n_l, n_w, n_t, c_h, $active_line
            #
            #
            #
            key_timer = 0
            # Event to update content
            $line_value.unbind('keyup').keyup ->
              clearTimeout key_timer
              key_timer = setTimeout ->
                val = $line_value.val()
                $active_line.html val
                shorten_this_line()
              , 100
              #
              #
              #
            #
            #
          #
          #
          #
          #
          font_family = $active_lines.css('font-family').replace /'/g, ''
          #
          $font_families.unbind 'change'
          $font_families.find('option').each ->
            $option = $ this
            if $option.val().toLowerCase() is font_family.toLowerCase()
              $option.attr 'selected', 'selected'
          $font_families.bind 'change', ->
            $active_lines.css
              'font-family': $font_families.val()
            shorten_all_lines()
          #
          #
          #
          text_align = $active_lines.css('text-align')
          #
          $text_align.unbind('click')
          $text_align.filter('[align='+text_align+']').make_active()
          $text_align.click ->
            $t_a = $ this
            $t_a.make_active()
            #
            $active_lines.css
              'text-align': $t_a.attr 'align'
              'width': max_l
              'left': min_l
              #
            #
            shorten_all_lines()
          #
          #
          #
          #
          font_size = Math.round $active_lines.height()
          #
          $font_size.unbind('change')
          #
          found_size = false
          $font_size.find('option').each ->
            unless found_size
              $option = $ this
              #
              if $option.val()*1 is font_size*1
                $option.attr 'selected', 'selected'
                found_size = true
              #
              if $option.val()*1 > font_size*1
                $new_option = $ '<option value="'+font_size+'">'+font_size+'</option>'
                $option.before $new_option
                $new_option.attr 'selected', 'selected'
                found_size = true
          #
          $font_size.change ->
            size_px = $font_size.val() + 'px'
            $active_lines.css
              'height': size_px
              'font-size': size_px
              'line-height': size_px
            #
            shorten_all_lines()
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
          $areas.eq(0).make_active()
          #
        else if $active_qr.length
          #
          $areas.eq(1).make_active()
          #
          #
          #
          qr_style = 'round'
          for item in active_theme.items
            if item.type is 'qr'
              qr_style = item.style
          #
          #
          $qr_style.unbind('click')
          $qr_style.filter('[qr_style='+qr_style+']').make_active()
          $qr_style.click ->
            $q_s = $ this
            $q_s.make_active()
            #
            #
            for item,item_i in active_theme.items
              if item.type is 'qr'
                #
                active_theme.items[item_i].qr_style = $q_s.attr 'qr_style'
                #
                alpha = Math.round(item.color_2_opacity * 255).toString 16
                #
                $active_qr.attr 'src', '/qr/'+item.color+'/'+item.color_2+alpha+'/'+$q_s.attr 'qr_style'+''
                #
                theme_modified()
          #
          #
          #
          #
          color_2_opacity = 0
          for item in active_theme.items
            if item.type is 'qr'
              color_2_opacity = item.color_2_opacity
          #
          $color_2_opacity.unbind('change')
          #
          $color_2_opacity.find('option').each ->
            $option = $ this
            #
            if $option.val()*1 is Math.round(color_2_opacity*100)
              $option.attr 'selected', 'selected'
          #
          $color_2_opacity.change ->
            color_2_opacity = $color_2_opacity.val()/100
            #
            for item,item_i in active_theme.items
              if item.type is 'qr'
                #
                active_theme.items[item_i].color_2_opacity = color_2_opacity
                #
                alpha = Math.round(color_2_opacity * 255).toString 16
                #
                $active_qr.attr 'src', '/qr/'+item.color+'/'+item.color_2+alpha+'/'+item.qr_style+''
                #
                theme_modified()
            #
          #
          #
          #
          #
          #
        else if $active_image.length
          #
          $areas.eq(2).make_active()
          #
          #
        else
          #
          $areas.eq(3).make_active()
          $show_themes.hide()
          #
        #
        #
        #
        #
        #
        $color_pickers = $home_designer.find '.color_picker:visible'
        #
        $color_pickers.each (i) ->
          $color_picker = $ this
          #
          #
          #
          if $active_lines.length
            $color_picker.css
              background: $active_lines.css 'color'
          #
          #
          #
          if $active_image.length
            #
            color = get_hex_color $active_image.find('.color').css 'background-color'
            #
            #
            $color_picker.css
              background: '#' + color or 'FFF'
          #
          #
          if $active_qr.length
            #
            for item in active_theme.items
              if item.type is 'qr'
                if i is 0
                  $color_picker.css
                    background: '#' + item.color
                if i is 1
                  $color_picker.css
                    background: '#' + item.color_2
          #
          #
          #
          #
          $color_picker.unbind('click').click (e) ->
            $color_window = $ '<div class="color-window-guy" />'
            $color_button = $ '<div class="button normal small">Save</div>'
            $color_window.colorpicker
              color: $color_picker.css 'background-color'
              rgb: false
              onSelect: (new_color) ->
                #
                #
                #
                $color_picker.css
                  background: new_color
                #
                #
                #
                if $active_qr.length
                  #
                  #
                  #
                  new_color = new_color.replace /#/, ''
                  new_color = new_color.substr 0,6
                  #
                  #
                  #
                  #
                  #
                  #
                  #
                  #
                  for item,item_i in active_theme.items
                    if item.type is 'qr'
                      if i is 0
                        active_theme.items[item_i].color = new_color
                        item.color = new_color
                      if i is 1
                        active_theme.items[item_i].color_2 = new_color
                        item.color_2 = new_color
                      #
                      #
                      #
                      #
                      # Calculate the alpha
                      alpha = Math.round(item.color_2_opacity * 255).toString 16
                      #
                      #
                      #
                      #
                      #
                      $active_qr.attr 'src', '/qr/'+item.color+'/'+item.color_2+alpha+'/'+item.qr_style+''
                      #
                      #
                      #
                      #
                      theme_modified()
                      #
                      #
                  #
                #
                $active_lines.each ->
                  $a = $ this
                  $a.css
                    'color': new_color
                  #
                  theme_modified()
                #
                $active_image.each ->
                  $a = $ this
                  #
                  $a.find('img').hide()
                  $a.find('.color').show().css
                    'background-color': new_color
                  #
                  theme_modified()
                  
            #
            $(document.body).append $color_window
            #
            $color_window.append $color_button
            #
            #
            #
            $color_window.css
              position: 'absolute'
              zIndex: 2000
            #
            #
            cp_o = $color_picker.offset()
            n_t = cp_o.top - $color_window.outerHeight() + $color_picker.outerHeight() + 4
            n_l = cp_o.left - 4
            n_r = null
            if n_l+$color_window.outerWidth() > $(window).width()
              n_l = null
              n_r = 0
            if n_t < $body.scrollTop()
              n_t = $body.scrollTop()
            $color_window.css
              top: n_t
              left: n_l
              right: n_r
            $color_button.css
              position: 'absolute'
              width: 80
              bottom: 34
              right: 14
            #
            #
            #
            body_click_event = (e) ->
              $t = $ e.target
              $to_check = $t.closest('.color-window-guy').add $t
              unless $to_check[0] is $color_window[0] and $t[0] isnt $color_button[0]
                $color_window.remove()
              else
                $body.one 'click', body_click_event
            e.preventDefault()
            setTimeout ->
              $body.one 'click', body_click_event
              $modes = $color_window.find '.ui-colorpicker-mode'
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
      $editor.unbind().mousedown (e) ->
        #
        editor_offset = $editor.offset()
        #
        x = e.pageX
        y = e.pageY
        #
        l = x - editor_offset.left
        t = y - editor_offset.top
        #
        $target = $ e.target
        if $target.hasClass('close_button') or $target.hasClass('resize_button') or $target.parent().hasClass('resize_button')
          return
        else
          e.preventDefault()
        #
        did_move_mouse = false
        #
        $active_lines = $editor.find '.active'
        $possible_lines = $editor.find('.line, .qr, .img').filter ':visible'
        $usable_lines = $ ''
        $clicked_lines = $ ''
        #
        #
        #
        #
        $possible_lines.each (i) ->
          $possible_line = $ this
          #
          #
          position = $possible_line.position()
          width = $possible_line.width()
          height = $possible_line.height()
          #
          unless l < position.left+width and l > position.left and t < position.top+height and t > position.top
            #
            $usable_lines = $usable_lines.add $possible_line
            #
          else
            #
            $clicked_lines = $clicked_lines.add $possible_line
            #
          #
        #
        last_z_index = 0
        $clicked_line = $ ''
        $clicked_lines.each ->
          $this_clicked_line = $ this
          z = $this_clicked_line.css 'z-index'
          if z > last_z_index
            $clicked_line = $this_clicked_line
            last_z_index = z
        #
        #
        # Position variables for starting out
        found_line = false
        #
        $active_lines.each ->
          $active_line = $ this
          #
          #
          position = $active_line.position()
          width = $active_line.width()
          height = $active_line.height()
          $active_line.data 'position', position
          #
          if l < position.left+width and l > position.left and t < position.top+height and t > position.top and (width isnt max_l or  height isnt max_t)
            #
            found_line = true
            #
            #
          #
        #
        if found_line
          #
          #
          move_event = (e_2) ->
            $active_lines.each ->
              $active_line = $ this
              #
              #
              position = $active_line.data 'position'
              width = $active_line.width()
              height = $active_line.height()
              x_2 = e_2.pageX
              y_2 = e_2.pageY
              #
              n_l = position.left - (x - x_2)
              n_t = position.top - (y - y_2)
              #
              n_l = min_l if n_l < min_l
              n_t = min_t if n_t < min_t
              #
              n_l = max_l-width if n_l+width > max_l
              n_t = max_t-height if n_t+height > max_t
              #
              $active_line.css
                left: n_l
                top: n_t
              #
              #
              move_my_buttons n_l, width, n_t, height, $active_line
              #
            e_2.preventDefault()
          #
          #
          $body.one 'mouseup', (e_3) ->
            e_3.preventDefault()
            $body.unbind 'mousemove', move_event
          #
          $body.unbind('mousemove').mousemove move_event
          #
        else
          #
          $highlight_box = $ '<div class="highlight_box" />'
          $editor.append $highlight_box
          #
          $highlight_box.hide().css
            left: -4
            top: -4
            width: 0
            height: 0
          #
          move_event = (e_2) ->
            #
            did_move_mouse = true
            #
            $active_lines.removeClass 'active'
            #
            x_2 = e_2.pageX
            y_2 = e_2.pageY
            #
            n_l = l - (x - x_2)
            n_t = t - (y - y_2)
            #
            #
            e_2.preventDefault()
            #
            final = 
              left: if l < n_l then l else n_l
              top: if t < n_t then t else n_t
              height: Math.abs(n_t-t)
              width: Math.abs(n_l-l)
            #
            within = (x1,y1,x2,y2) -> x1 < final.left+final.width and x2 > final.left and y1 < final.top+final.height and y2 > final.top
            #
            $usable_lines.each ->
              $possible = $ this
              pos = $possible.position()
              w = $possible.width()
              h = $possible.height()
              if within pos.left,pos.top,pos.left+w,pos.top+h
                $possible.addClass 'active'
              else
                $possible.removeClass 'active'
            #
            new_active()
            #
            $highlight_box.show().css final
          #
          #
          $body.one 'mouseup', (e_3) ->
            e_3.preventDefault()
            unless did_move_mouse
              unless shift_pressed or ctrl_pressed
                $active_lines.removeClass 'active'
                $clicked_line.make_active()
              else
                $clicked_line.toggleClass 'active'
              new_active()
            $body.unbind 'mousemove', move_event
            $highlight_box.remove()
            add_remove_focus_event()
            setTimeout ->
              $home_designer.find('.line_value:first').focus().select()
            , 0
          #
          $body.unbind('mousemove').mousemove move_event
      #
      new_active()
      #
    #
    #
    #
    $add_qr = $home_designer.find '.add_qr'
    $add_qr.click ->
      setTimeout ->
        #
        $my_card = $editor.find '.fg:visible,.bg:visible'
        #
        $my_qr = $ '<img class="qr active" />'
        $my_card.append $my_qr
        #
        #
        $my_qr.attr 'src', '/qr/000000/FFFFFFFF/round/1?cards.ly'
        #
        $my_qr.show().css
          height: 129
          width: 130
          position: 'absolute'
          top: 62
          left: 387
        #
        new_active()
        #
        theme_modified()
        #
        $add_qr.hide()
    #
    $add_image = $home_designer.find '.add_image'
    $add_image.click ->
      #
      $upload_input.click()
      #
      setTimeout ->
        #
        $image = $ '<image class="img active" />'
        #
        $editor.find('.bg:visible,.fg:visible').append $image
        #
        $image.css
          left: 0
          top: 0
          width: 150
          height: 100
          position: 'absolute'
        #
        new_active()
        add_remove_focus_event()
        #
      , 0
    #
    $add_line = $home_designer.find '.add_line'
    $add_line.click ->
      #
      setTimeout ->
        #
        # find last visible line
        $last_line = $ ''
        last_top = 0
        last_left = 0
        $editor.find('.line:visible').each ->
          $t = $ this
          this_top = parseInt $t.css('top')
          this_left = parseInt $t.css('left')
          if this_top > last_top or (this_top is last_top and this_left > last_left)
            $last_line = $t 
            last_top = this_top
            last_left = this_left

        #
        n_l = parseInt $last_line.css 'left'
        n_t = parseInt $last_line.css 'top'
        c_h = $last_line.height()
        c_w = $last_line.width()
        #
        #
        $active_line = $ '<div class="line active" />'
        #
        $editor.find('.bg:visible,.fg:visible').append $active_line
        #
        $active_line.html('New line')
        #
        n_t = n_t + c_h + 10
        my_max_t = max_t - c_h
        if n_t > my_max_t
          n_t = my_max_t
          n_l = n_l + c_w
        t_a = $last_line.css 'text-align'
        my_max_l = max_l - c_w
        if n_l > my_max_l
          n_l = my_max_l
        #
        # Use last line for css
        $active_line.css
          position: 'absolute'
          left: n_l
          top: n_t
          width: c_w
          height: c_h
          'font-size': c_h+'px'
          'line-height': c_h+'px'
          'font-family': $last_line.css 'font-family'
          'text-align': t_a
        #
        new_active()
        add_remove_focus_event()
        #
        #
        $active_line.css
          width: 'auto'
        #
        n_w = $active_line.width()
        if t_a is 'right'
          n_l = n_l + c_w - n_w
        if t_a is 'center'
          n_l = n_l + (c_w - n_w)/2
        #
        $active_line.css
          left: n_l
          width: n_w
        #
        move_my_buttons n_l, n_w, n_t, c_h, $active_line
        #
        #
        #
        # focus
        setTimeout ->
          $home_designer.find('.line_value:first').focus().select()
        , 0
        #
        #
      , 0
    #
    #
    $front_back = $ '.front_back .option'
    $front_back.click ->
      $f_b = $ this
      #
      if theme_modified_timer isnt 0
        actually_save_active_theme()
      #
      $f_b.make_active()
      #
      setTimeout ->
        #
        $thumbs = $themes.find '.thumb'
        #
        #$thumbs.filter('.active').click()
        #
        side_text = $f_b.html().toLowerCase()
        #
        $front_back.each ->
          $f_b = $ this
          if $f_b.html().toLowerCase() is side_text
            $f_b.make_active()
        #
        #
        $fg = $thumbs.add($all_card).find '.fg'
        $bg = $thumbs.add($all_card).find '.bg'
        #
        #
        $first = $fg
        $second = $bg
        side = 1
        #
        if side_text is 'front'
          side = 0
          $first = $bg
          $second = $fg
        #
        $first.addClass 'collapsed'
        #
        #
        setTimeout ->
          $first.removeClass 'collapsed'
          $first.addClass 'collapsed2'
          $first.hide()
          $second.show()
          setTimeout ->
            $second.removeClass 'collapsed2'
          , 0
          #
          #
          if $editor.find('.qr:visible').length then $add_qr.hide() else $add_qr.show()
          #
          #
        , 500
        #
        #
        #
      ,0
    #
    #
    #
    #
    #
    #
    get_themes = ->
      $.ajax
        url: '/get-themes'
        success: (results) ->
          #
          for theme,i in results.themes
            #
            $new_thumb = $ '<div class="thumb"></div>'
            $new_thumb.attr
              id: theme._id
            #
            $fg_image = $ '<img class="fg" />'
            $fg_image.attr
              src: '/thumb/'+theme._id+''
            $new_thumb.append $fg_image
            #
            #
            $bg_image = $ '<img class="bg collapsed2" />'
            $bg_image.hide()
            $bg_image.attr
              src: '/thumb/'+theme._id+'/1'
            $new_thumb.append $bg_image
            #
            #
            if theme.user_id
              $ours_yours.show()
              $my_themes.prepend $new_thumb
            else
              #
              $themes.append $new_thumb
            #
            #
          #
          $thumbs = $themes.find '.thumb'
          #
          $thumbs.hover ->
            $(this).addClass 'hover'
          , ->
            $(this).removeClass 'hover'
          #
          $thumbs.live 'click', ->
            #
            #
            if theme_modified_timer isnt 0
              actually_save_active_theme()
            #
            $thumb = $ this
            id = $thumb.attr 'id'
            #
            #
            $themes.find('.thumb').removeClass 'active'
            $thumb.addClass 'active'
            #
            $.ajax
              url: '/get-theme'
              data: JSON.stringify
                theme_id: id
              success: (results) ->
                theme = results.theme
                #
                active_theme = theme
                #
                #console.log 'AFTER GET:', active_theme.user_id
                #
                #
                side = $front_back.filter('.active').html().toLowerCase()
                #
                #
                $all_card.each ->
                  #
                  $this_card = $ this
                  #
                  $fg = $this_card.find '.fg'
                  if not $fg.length
                    $fg = $ '<div class="fg" />'
                    $fg.addClass 'collapsed2' if side is 'back'
                    $fg.hide() if side is 'back'
                    $this_card.append $fg
                  #
                  $bg = $this_card.find '.bg'
                  if not $bg.length
                    $bg = $ '<div class="bg" />'
                    $bg.addClass 'collapsed2' if side is 'front'
                    $bg.hide() if side is 'front'
                    $this_card.append $bg
                  #
                  #
                  $.create_card_from_theme
                    height: 300
                    width: 525
                    theme: theme
                    active_view: 0
                    card: $fg
                    side: 0
                  #
                  $.create_card_from_theme
                    height: 300
                    width: 525
                    theme: theme
                    active_view: 0
                    card: $bg
                    side: 1
                #
                card_loaded()
                #
                #
                if $editor.find('.qr:visible').length then $add_qr.hide() else $add_qr.show()
                #
                #
                order.active_theme_id = id
                #
                # And save it
                $.ajax
                  url: '/save-order'
                  data: JSON.stringify order
            #
            #
            #console.log id
          #
          #
          for thumb in $thumbs
            if thumb.id is order.active_theme_id
              $thumb = $ thumb
              #
              # Activate that theme
              $thumb.click()
              #
              # And scroll to it
              $themes.scrollTo $thumb,
                offset: 
                  left: 0
                  top: -20
              #
              #
    #
    #
    #
    #
    #
    # -------
    # Email (and phone)
    # -------
    #
    $order_email = $ '.order_email'
    order_email_timer = 0
    $order_email.keyup ->
      clearTimeout order_email_timer
      order_email_timer = setTimeout ->
        order.email = $order_email.val()
        $.ajax
          url: '/save-order'
          data: JSON.stringify order
      , 3000
    #
    $order_phone = $ '.order_phone'
    order_phone_timer = 0
    $order_phone.keyup ->
      clearTimeout order_phone_timer
      order_phone_timer = setTimeout ->
        order.phone = $order_phone.val()
        $.ajax
          url: '/save-order'
          data: JSON.stringify order
      , 3000
    #
    $order_alerts = $ '.order_alerts .option'
    $order_alerts.click ->
      $o_a = $ this
      $o_a.make_active()
      #
      #
      order.alerts = $o_a.html().toLowerCase()
      $.ajax
        url: '/save-order'
        data: JSON.stringify order
    #
    #
    #
    #
    #
    # -------
    # Quantity
    # -------
    $quantity = $ '.quantity_form .option'
    #
    $total_price = $ '.total_price'
    #
    $preview_count = $ '.preview_count'
    #
    $quantity.click ->
      $q = $ this
      #
      #
      $preview_count.html '<div class="large">'+$q.attr('cards')+'</div><div class="small">x</div>'
      #
      # Make this guy active
      $q.make_active()
      #
      order.amount = $q.attr('cost') - discount
      order.quantity = $q.attr 'cards'
      #
      # And save it
      $.ajax
        url: '/save-order'
        data: JSON.stringify order
      #
      #
      #
      #
      #
      $total_price.html order.amount
    #
    #
    #
    #
    #
    # -------
    # URL
    # -------
    #
    $set_link = $ '.set_link'
    order_link_timer = 0
    $set_link.keyup ->
      clearTimeout order_link_timer
      order_link_timer = setTimeout ->
        order.url = $set_link.val()
        $.ajax
          url: '/save-order'
          data: JSON.stringify order
      , 3000
    #
    #
    #
    #
    #
    #
    $checkout_form = $ '.checkout'
    #
    # --------------
    # Address Search
    # --------------
    #
    $street = $checkout_form.find '.street'
    $map = $checkout_form.find '.map'
    $zip_code = $checkout_form.find '.zip_code'
    $full_address = $checkout_form.find '.full_address'
    #
    #
    #
    load_map = (map) ->
      $new_img = $ '<img />'
      if map.full_address
        coordinates = map.latitude+','+map.longitude
        $new_img.attr 'src', '//maps.googleapis.com/maps/api/staticmap?center='+coordinates+'&markers=color:red%7Clabel:V%7C'+coordinates+'&zoom=13&size=350x110&sensor=false'
        $full_address.html map.full_address.replace /,/, '<br>'
      else
        $new_img.attr 'src', null
      #
      $map.html ''
      $map.append $new_img
    #
    #
    #
    check_address_timer = 0
    maybe_check_address = ->
      $map.html 'Waiting for input ...'
      $full_address.html ''
      clearTimeout check_address_timer
      check_address_timer = setTimeout ->
        #
        $map.html 'Searching now ...'
        #
        # 
        $.ajax
          url: '/search-address'
          data: JSON.stringify
            street: $street.val()
            zip_code: $zip_code.val()
          success: (results) ->
            if results.latitude
              load_map results
        #
        #
      , 1000
    #
    $street.keyup maybe_check_address
    $zip_code.keyup maybe_check_address
    #
    # ----------------
    # END Address
    # ----------------
    #
    #
    #
    #
    #
    #
    #
    #
    #
    $.ajax
      url: '/get-order'
      success: (results) ->
        #
        #
        ###
        TODO

        easy exercise

        find all lines of code like the following:

          if something
            something_else
        
        where something_else is just one line and simple, and convert it to:

          something_else if something

        or:

          something_else unless something

        if the origin looked like:

          if not something
            something_else

        ###
        #
        #
        if results.order
          #
          order = results.order
          #
        #
        if order.quantity
          $a_q = $quantity.filter('[cards='+order.quantity+']')
          $a_q.click()
        else
          $quantity.first().click()
        #
        #
        #
        if order.values
          $.line_copy = order.values
        #
        if order.email
          $order_email.val order.email
        #
        if order.phone
          $order_phone.val order.phone
        #
        if order.alerts
          $order_alerts.each ->
            $o_a = $ this
            if $o_a.html().toLowerCase() is order.alerts
              $o_a.make_active()
        #
        #
        #
        #
        if order.url
          $set_link.val order.url
        #
        #
        #
        #
        #
        if order.full_address
          load_map order
          #
          $street.val order.address
          $zip_code.val order.city
          #
          #$street.keyup()
          #$zip_code.keyup()
          #
          #
        #
        #
        #
        #
        #
        if not $thumbs
          get_themes()
    #
    #
    #
    #
    #
    $required = $ '.required'
    $optional = $ '.optional'
    $prev_t = $ ''
    #
    $required.add($optional).each (i) ->
      $t = $ this
      do ($t,$prev_t) ->
        $s = $t.next('.symbol')
        $a = $t.add $s
        #
        pattern = $t.attr('pattern')
        reg_ex = new RegExp pattern
        #
        $t.keyup (e) ->
          #
          val = $t.val()
          #
          truth_expression = val.match reg_ex
          #
          if $t.hasClass 'credit_card'
            truth_expression = val.luhn_check()
          #
          if truth_expression
            $a.removeClass 'typing'
            $a.addClass 'filled_in'
            $s.html '✓'
          else
            $a.removeClass 'filled_in'
            unless $t.hasClass 'optional'
              $s.html '*'
        #
        $t.blur ->
          unless $t.hasClass 'optional'
            val = $t.val()
            unless val.match reg_ex
              $a.addClass 'typing'
              $a.removeClass 'filled_in'
              $s.html '*'
            #
          $prev_t.blur()
          #
      $prev_t = $t
    #
    #
    #
    if env is 'development'
      Stripe.setPublishableKey 'pk_ZHhE88sM8emp5BxCIk6AU1ZFParvw'
    else
      Stripe.setPublishableKey 'pk_5U8jx27dPrrPsm6tKE6jnMLygBqYg'
    #
    #
    #
    #
    $purchase_button = $ '.purchase'
    $purchase_button.click ->
      $required.last().blur()
      $errored = $required.filter '.typing'
      #
      use_credit_card = $('[name=use_credit_card]:checked')
      #
      has_an_existing_card = use_credit_card.length and use_credit_card.val() is 'existing'
      #
      #
      if has_an_existing_card
        #
        #console.log $errored
        #
        $errored = $errored.not '.credit_card,.cvc'
      #
      if $errored.length
        $body.scrollTo $errored.first(),
          offset:
            left: 0
            top: -28
          duration: 500
        setTimeout ->
          $errored.fadeOut(200).fadeIn(200).fadeOut(200).fadeIn().fadeOut(200).fadeIn(200)
        , 500
      else
        #
        #
        #
        $.load_loading {}, (loading_close) ->
          #
          $.ajax
            url: '/validate-purchase'
            success: (result) ->
              if result.err
                loading_close()
                $.load_alert
                  content: result.err
              else if result.success
                #
                # Set up a default
                token = false
                #
                # This gets called after we either get a token
                # OR we already have a payment maybe
                load_final = ->
                  $.ajax
                    url: '/confirm-purchase'
                    data: JSON.stringify
                      token: token
                    success: (result) ->
                      #console.log result
                      if result.err
                        loading_close()
                        $.load_alert
                          content: 'We tried that, and the credit card processor told us:<p><blockquote>' + result.err + '</blockquote></p>'
                      else
                        #console.log result
                        if result.charge.paid
                          document.location.href = '/cards/thank-you'
                        else
                          loading_close()
                          $.load_alert
                            content: 'Our apoligies, something went wrong, please try again later'
                          
                    error: ->
                      loading_close()
                      $.load_alert
                        content: 'Our apoligies, something went wrong, please try again later'
                #
                #
                # See if they filled a card in
                if $('.credit_card').val() and $('.cvc').val()
                  #
                  # Create a token based on the card number perhaps
                  Stripe.createToken
                      number: $('.credit_card').val()
                      cvc: $('.cvc').val()
                      exp_month: $('.card_expiry_month').val()
                      exp_year: $('.card_expiry_year').val()
                  , order.amount, (status, response) ->
                    #console.log status, response
                    if status is 200
                      token = response.id
                      load_final()
                    else
                      loading_close()
                      $.load_alert
                        content: 'We tried that, and the credit card processor told us:<p><blockquote>' + response.error.message + '</blockquote></p>'
                #
                #
                else if has_an_existing_card
                  load_final()
                #
                #
                else
                  $.load_alert
                    content: 'Please enter a credit card'
              else
                loading_close()
                $.load_alert
                  content: 'Our apoligies, something went wrong, please try again later'
            error: ->
              loading_close()
              $.load_alert
                content: 'Our apoligies, somethieng went wrong, please try again later'
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
  $login_form = $ '.login_form'
  $login_form.submit ->
    $.load_loading {}, (loading_close) ->
      $.ajax
        url: '/login'
        data: JSON.stringify
          email: $login_form.find('.email').val()
          password: $login_form.find('.password').val()
        success: (result) ->
          loading_close()
          if result and result.success
            document.location.href = '/cards'
          else if result and result.err
            $.load_alert
              content: result.err
          else
            $.load_alert
              content: 'Something went wrong, please try again later.'
        error: ->
          loading_close()
          $.load_alert
            content: 'Something went wrong, please try again later.'

    false
  #
  #
  #
  #
  #
  #
  $set_password_form = $ '.set_password_form'
  $set_password_form.submit ->
    $.load_loading {}, (loading_close) ->
      $.ajax
        url: '/set-password'
        data: JSON.stringify
          password: $set_password_form.find('.set_new_password').val()
        success: (result) ->
          loading_close()
          if result and result.success
            $.load_alert
              content: 'Password set.'
          else if result and result.err
            $.load_alert
              content: result.err
          else
            $.load_alert
              content: 'Something went wrong, please try again later.'
        error: ->
          loading_close()
          $.load_alert
            content: 'Something went wrong, please try again later.'

    false
  #
  #
  #
  #
  $forgot_password = $ '.forgot_password'
  #
  $forgot_password.click ->
    $.load_modal
      content: '<p>Please enter your email address:</p><input class="email_to_reset" />'
      buttons: [
        action: (close) ->
          email = $('.email_to_reset').val()
          if email
            $.load_loading {}, (loading_close) ->
              $.ajax
                url: '/send-password' 
                data: JSON.stringify
                  email: email
                success: (result) ->
                  loading_close()
                  if result and result.success
                    $.load_alert
                      content: 'Email sent, please check your inbox.'
                  else if result and result.err
                    $.load_alert
                      content: result.err
                  else
                    $.load_alert
                      content: 'Something went wrong, please try again later.'
                error: ->
                  loading_close()
                  $.load_alert
                    content: 'Something went wrong, please try again later.'
              close()
        label: 'Send Login Link'
      ,
        action: (close) -> 
          close()
        label: 'Cancel'
        class: 'gray'
      ]
    false
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
  discount = 0
  #
  #
  #
  # Coupon Collection
  $('.coupon').click ->
    $.load_modal
      content: '<p>Please enter a coupon code:</p><input class="coupon_code" />'
      buttons: [
        action: (close) ->
          coupon_code = $('.coupon_code').val()
          $.load_loading {}, (loading_close) ->
            $.ajax
              url: '/validate-coupon' 
              data: JSON.stringify
                coupon_code: coupon_code
              success: (result) ->
                loading_close()
                if result and result.discount
                  discount = result.discount
                  $quantity.filter('.active').click()
                  $.load_alert
                    content: 'Discount of $'+result.discount+' applied.'
                else
                  $.load_alert
                    content: 'I\'m sorry, that code doesn\'t appear to be valid still.'
              error: ->
                loading_close()
                $.load_alert
                  content: 'Something went wrong, please try again later.'
            close()
        label: 'Apply'
      ,
        action: (close) -> 
          close()
        label: 'Cancel'
        class: 'gray'
      ]
    false
  #
  #
  #
  #
  #
  #


  #################################################################
  #
  #
  # URL GROUPS
  #
  #
  #
  $url_groups = $ '.url_group'
  $url_groups.each ->
    $g = $ this
    g_id = $g.attr('id')
    $rows = $g.find '.link_row[id]'
    $edit_button = $g.find '.link_row.edit'
    #
    #
    #
    # Set up the main editing function
    $main_row = $g.find '.link_main_row'
    # Start up some events!
    main_start_edit = ->
      #
      #
      #
      $redirect = $main_row.find '.redirect_to'
      #
      $edit_button.hide()
      #
      # Set up the link input
      action = $redirect.html()
      $redirect.html '<textarea placeholder="http://">'+action+'</textarea><div class="buttons"><div class="button normal small save">Save</div><div class="button gray small cancel">X</div></div><div class="clear" /><div class="status" />'
      $add_button = $redirect.find '.save'
      $textarea = $redirect.find 'textarea'
      $status = $redirect.find '.status'
      $cancel_button = $redirect.find '.cancel'
      #
      #
      #
      $cancel_button.click ->
        $textarea.val action
        $body.click()
      #
      $add_button.click -> $body.click()
      #
      $textarea.focus()[0].select()
      #
      edit_timer = 0
      set_edit_timers = ->
        clearTimeout edit_timer
        if $textarea.val()
          edit_timer = setTimeout ->
            $status.stop(true,true).show()
            $status.html 'Saving...'
            $.ajax
              url: '/save-main-redirect'
              data: JSON.stringify
                url_group_id: g_id
                redirect_to: $textarea.val()
              success: (result) ->
                $status.html 'Unknown Error'
                if result
                  if result.err
                    $status.html err
                  else if result.success
                    $status.html 'Saved'
                    $status.stop(true,true).delay(1000).fadeOut(2000)
              error: ->
                $status.html 'Unknown Error'
          , 500
      #
      #
      $textarea.keydown (e) ->
        set_edit_timers()
        if e.keyCode is 13 or e.keyCode is 9
          e.preventDefault()
          $body.click()
      #
      #
      #
      remove_me = (e) ->
        $target = $ e.target
        if $target[0] isnt $main_row[0] and $target.closest('.link_main_row')[0] isnt $main_row[0]
          set_edit_timers()
          $redirect.html $textarea.val().replace('http://','')
          $main_row.one 'click', main_start_edit
          if $g.find('textarea').length is 0
            $edit_button.show()
          $body.unbind 'click', remove_me
      $body.bind 'click', remove_me
      #
      #
      #

    $main_row.one 'click', main_start_edit
    #
    #
    #
    # Create the Edit event we'll use a couple of places
    bind_edit_event_to = ($r) ->
      #
      #
      $range = $r.find '.range'
      $redirect = $r.find '.redirect_to'
      # Start up some events!
      start_edit = ->
        #
        #
        $edit_button.hide()
        #
        #
        # Set up the range input
        range = $range.html().replace /#/, ''
        $range.html '<div class="helper">card #\'s</div><input value="'+range+'" />'
        $input = $range.find 'input'
        #
        # Set up the link input
        action = $redirect.html()
        $redirect.html '<textarea placeholder="http://">'+action+'</textarea><div class="buttons"><div class="button normal small save">Save</div><div class="button gray small cancel">X</div></div><div class="clear" /><div class="status" />'
        $textarea = $redirect.find 'textarea'
        $add_button = $redirect.find '.save'
        $cancel_button = $redirect.find '.cancel'
        $status = $redirect.find '.status'
        #
        #
        do_add_new = ->
          $edit_button.click()
          
        #
        $cancel_button.click -> 
          $input.val range
          $textarea.val action
          $body.click()
        #
        $add_button.click do_add_new
        #
        edit_timer = 0
        set_edit_timers = ->
          clearTimeout edit_timer
          if $input.val() and $textarea.val()
            edit_timer = setTimeout ->
              $status.stop(true,true).show()
              $status.html 'Saving...'
              $.ajax
                url: '/save-redirect'
                data: JSON.stringify
                  url_group_id: g_id
                  range: $input.val()
                  redirect_to: $textarea.val()
                success: (result) ->
                  $status.html 'Unknown Error'
                  if result
                    if result.err
                      $status.html err
                    else if result.success
                      $status.html 'Saved'
                    $status.stop(true,true).delay(1000).fadeOut(2000)
                error: ->
                  $status.html 'Unknown Error'
            , 500
        #
        $textarea.keydown (e) ->
          set_edit_timers()
          if e.keyCode is 13 or e.keyCode is 9
            e.preventDefault()
            do_add_new()
        #
        $input.keydown (e) ->
          set_edit_timers()
          if e.keyCode is 13
            e.preventDefault()
            do_add_new()
        #
        #
        $r.addClass 'expanded'
        #
        remove_me = (e) ->
          $target = $ e.target
          if $target[0] isnt $r[0] and $target.closest('.link_row')[0] isnt $r[0]
            $r.removeClass 'expanded'
            set_edit_timers()
            if $input.val() or $textarea.val()
              $range.html '#'+$input.val()
              $redirect.html $textarea.val().replace('http://','')
              $r.one 'click', start_edit
            else
              $r.remove()
            if $g.find('textarea').length is 0
              $edit_button.show()
            $body.unbind 'click', remove_me
            if typeof($v_dialog) isnt 'undefined'
              $v_dialog.remove()
        $body.bind 'click', remove_me
        #
        #
        #
        # Only on visited ones, do this stuff
        url_string = $r.attr 'url_string'
        if $r.find('.visited').html() isnt ''
          # 
          # Creating some elements
          $v_dialog = $ '<div class="visit_dialog" />'
          $r.append '<div class="clear" />'
          $r.append $v_dialog
          $v_dialog.html 'Loading ...'
          $.ajax
            url: '/get-visits'
            data: JSON.stringify
              url_string: url_string
            success: (result) ->
              $v_dialog.html ''
              if result.visits
                for visit in result.visits
                  $item = $ '<div class="item" />'
                  $item.append '<div class="cell">'+new Date(visit.date_added).format('m/dd/yyyy h:MM tt')+'</div>'
                  $item.append '<div class="cell">'+visit.browser+'</div>'
                  $item.append '<div class="cell">'+visit.location+'</div>'
                  $item.append '<div class="cell">'+new Date(visit.date_added).ago()+'</div>'
                  $v_dialog.append $item
        #
        # On non visited ones, we focus and select
        else
          #
          if range
            $textarea.focus()[0].select()
          else
            $input.focus()[0].select()
      #
      #
      $r.one 'click', start_edit
      #
      #
      #
      #
    #
    #
    $edit_button.click (e) ->
      $new_row = $ '<div class="link_row"><div class="visited" /><div class="range" /><div class="redirect_to" /><div class="time" /></div>'
      $edit_button.before $new_row
      bind_edit_event_to $new_row
      setTimeout ->
        $new_row.click()
      , 0
    #
    #
    # Bind the default events to the existing markup
    $rows.each ->
      #
      # Just Setting up Variables
      $r = $ this
      #
      #
      bind_edit_event_to $r
      #
      #
  #
  #
  #
  # END URL GROUPS
  #
  #
  #
  #################################################################






  #
  # For the print page only
  current_url = document.location.href
  if current_url.match /print/
    #
    url_parts = current_url.match /print\/(0|1)\/([^\/]*)\/([^\/]*)/
    #
    side = url_parts[1]*1
    order_id = url_parts[2]
    theme_id = url_parts[3]
    #
    $print = $ '.print'
    #
    $.ajax
      url: '/get-theme'
      data: JSON.stringify
        theme_id: theme_id
      success: (results) ->
        #
        theme = results.theme
            #
        $.ajax
          url: '/get-order'
          data: JSON.stringify
            order_id: order_id
          success: (results) ->
            #
            order = results.order
            #
            $.line_copy = order.values
            #
            $.ajax
              url: '/get-url-group'
              data: JSON.stringify
                order_id: order_id
              success: (result) ->
                #
                url_group = result.url_group
                #
                #
                #console.log 'AFTER GET:', active_theme.user_id
                #
                #
                $background_only = $.create_card_from_theme
                  height: 2
                  width: 3.5
                  units: 'in'
                  side: side
                  theme: theme
                #
                $background_only.find('.line,.qr').remove()
                #
                $top_buffer = $background_only.clone().css
                  height: '.125in'
                  overflow: 'hidden'
                $top_buffer.find('.img').each ->
                  $img = $ this
                  c_t = parseInt $img.css 'top'
                  $img.css
                    top: (c_t - 1.875) + 'in'
                #
                #
                $bottom_buffer = $background_only.clone().css
                  height: '.125in'
                  overflow: 'hidden'
                #
                #
                #
                #
                #
                $right_buffer = $background_only.clone().css
                  width: '.125in'
                  overflow: 'hidden'
                $right_buffer.find('.img').each ->
                  $img = $ this
                  c_l = parseInt $img.css 'left'
                  $img.css
                    left: (c_l - 3.375) + 'in'
                #
                #
                $left_buffer = $background_only.clone().css
                  width: '.125in'
                  overflow: 'hidden'
                #
                #
                #
                #
                for url,i in url_group.urls
                  #
                  if i%10 is 0
                    $print.append $top_buffer.clone().css
                      'margin-left': '.125in'
                    $print.append $top_buffer.clone().css
                      'margin-right': '.125in'
                  #
                  if i%2 is 0
                    $print.append $left_buffer.clone()
                  #
                  $this_card = $ '<div class="card_container" />'
                  #
                  ###
                  $bg = $ '<div class="bg" />'
                  $bg.addClass 'collapsed2' if side is 'front'
                  $bg.hide() if side is 'front'
                  $this_card.append $bg
                  ###
                  #
                  $fg = $.create_card_from_theme
                    height: 2
                    width: 3.5
                    units: 'in'
                    theme: theme
                    side: side
                    card_number: url.card_number
                    url: 'cards.ly/'+url.url_string
                  
                  #
                  $this_card.append $fg
                  #
                  ###
                  $.create_card_from_theme
                    height: 300
                    width: 525
                    theme: theme
                    card: $bg
                    side: 1
                  ###
                  #
                  $print.append $this_card
                  #
                  #
                  if i%2 is 1
                    $print.append $right_buffer.clone()
                  #
                  if i%10 is 9
                    $print.append $bottom_buffer.clone().css
                      'margin-left': '.125in'
                    $print.append $bottom_buffer.clone().css
                      'margin-right': '.125in'
                #
                #







  #
  #
  # For the thank you page only
  $try_conversion = $ '.try_conversion'
  if $try_conversion.length
    $.ajax
      url: '/get-conversion'
      success: (result) ->
        #console.log result
        if result.order
          #
          order = result.order
          #
          #
          _gaq.push ['_addTrans',
            order.order_number,
            'Cardsly',
            order.amount,
            0,
            0,
            order.city
          ]
          _gaq.push ['_addItem',
            order.order_number,
            'SKU',
            'Name',
            'Category',
            order.amount/order.quantity,
            order.quantity
          ]
          _gaq.push ['_trackTrans']
  










  #
  # For the cards page only
  $url_controls = $ '.url_controls'
  if $url_controls.length
    #
    $groups = $url_controls.find '.groups'
    #
    $.ajax
      url: '/get-url-groups'
      success: (result) ->
        if result.url_groups
          for url_group in result.url_groups
            #
            console.log url_group
            #
            $url_group = $ '<div class="group" />'
            #
            #
            $url_group.append '<img src="/render/158/90/'+url_group.order_id+'" />'
            #
            $label = $ '<div class="label" />'
            urls = url_group.urls
            #
            $label.html '#' + urls[0].card_number + ' - ' + urls[urls.length-1].card_number
            #
            $url_group.append $label
            #
            #
            $groups.append $url_group






  #################################################################
  #
  #
  # BEGIN SETTINGS
  #
  #
  #
  $('.printed').click ->
    $t = $ this
    $o = $t.closest '.order_row'
    order_id = $o.attr 'order_id'
    $s = $o.find '.status'
    $s.html 'Saving...'
    $.ajax
      url: '/update-order-status'
      data: JSON.stringify
        order_id: order_id
        status: 'Printed'
  $('.shipped').click ->
    $t = $ this
    $o = $t.closest '.order_row'
    order_id = $o.attr 'order_id'
    $s = $o.find '.status'
    $s.html 'Saving...'
    $.ajax
      url: '/update-order-status'
      data: JSON.stringify
        order_id: order_id
        status: 'Shipped'
      success: (result) ->
        if result.success
          $s.html 'Shipped'
          $o.delay(500).fadeOut()
    false
  #
  #
  # END SETTINGS
  #
  #
  #
  #################################################################
  
  #
  #
  #
