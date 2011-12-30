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
    theme: null
    active_view: 0
    card: null
    side: 'front'
  #
  if options
    $.extend settings, options
  
  #
  # Set Constants
  theme_template = settings.theme.theme_templates[settings.active_view] or settings.theme.theme_templates[0]
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
    #
    #
    #
    $my_qr = $my_card.find('.qr')
    if not $my_qr.length
      $my_qr = $ '<img class="qr" /></div>'
      $my_card.append $my_qr
    #
    #
    #
    $lines = $my_card.find '.line'
    #
    #
    for pos,i in theme_template.lines
      if $lines.eq(i).length
        $li = $lines.eq(i)
      else
        $li = $ '<div class="line">' + $.line_copy[i] + '</div>'
        $li.appendTo $my_card
    #
    #
    #
    #
    if settings.side is 'back' and not $my_card.hasClass 'preview_2'
      #
      $lines.hide()
      #
      $my_qr.hide()
      #
    else
      # Calculate the alpha
      alpha = Math.round(theme_template.qr.color2_alpha * 255).toString 16
      #
      #
      $my_qr.attr 'src', '/qr/'+theme_template.qr.color1+'/'+theme_template.qr.color2+alpha+'/'+(theme_template.qr.style or 'round')+''
      #
      $my_qr.show().css
        height: theme_template.qr.h/100 * settings.height
        width: theme_template.qr.w/100 * settings.width
        position: 'absolute'
        top: theme_template.qr.y/100 * settings.height
        left: theme_template.qr.x/100 * settings.width
        zIndex: 200
      #
      #
      #
      $lines = $my_card.find '.line'
      #
      #
      for pos,i in theme_template.lines
        $li = $lines.eq(i)
        #
        $li.show().css
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
    #
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
  #
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
  #
  if typeof(window.orientation) isnt 'undefined'
    check_orient = ->
      if window.orientation is 0 or window.orientation is 180
        w = screen.width
        $('meta[name=viewport]').attr 'content', 'width=525, initial-scale='+(w/525)+', user-scalable=no'
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
  $dropdown = $ '.dropdown'
  $dropdown.each ->
    #
    $d = $ this
    #
    #
    $options = $d.find '.option'
    #
    $options.click ->
      $f = $ this
      $f.make_active()
    #
    $options.first().click()
    #
    $d.click ->
      unless $d.hasClass 'active'
        $d.addClass 'active'
        #
        #
        #
        setTimeout ->
          $body.one 'click', ->
            $d.removeClass 'active'
            $d.find('.bg_scroll').scrollTo $d.find '.active'
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
  ctrl_pressed = false
  shift_pressed = false
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
      console.log 'undo'
    #
    # Redo
    if ctrl_pressed and shift_pressed and k is 90
      e.preventDefault()
      console.log 'redo'
    #
    #
    #
    # Up and Down
    if k is 38 or k is 40
      $active_dropdown = $dropdown.filter '.active'
      if $active_dropdown.length
        $active_option = $active_dropdown.find '.active'
        e.preventDefault()
        if k is 38
          $new_option = $active_option.prev()
        if k is 40
          $new_option = $active_option.next()
        #
        if $new_option.length
          #
          $new_option.make_active()
          #
          $active_dropdown.find('.bg_scroll').scrollTo $new_option
    #
    if k is 37 or k is 39 or k is 13 or k is 9 or k is 32
      $active_dropdown = $dropdown.filter '.active'
      if $active_dropdown.length
        e.preventDefault()
        $body.click()
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
    active_theme_id = '4ec3fb7b3bf1fc0100000042'
    #
    #
    $all_card = $home_designer.find '.card'
    #
    $card = $all_card.filter ':not(.preview_2)'
    #
    #
    #
    $editor = $all_card.filter '.editor'
    $line_value = $home_designer.find '.line_value'
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
    $areas = $home_designer.find '.area'
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
    $themes = $home_designer.find '.themes'
    $thumbs = undefined
    #
    $notify_form = $ '.notify_form'
    #
    $link_items = $notify_form.find '.link_items'
    #
    #
    #
    io_session = io.connect('/order_form')
    io_session.on 'connect', () ->
      #
      #
      #
      #
      #
      #
      #
      #
      io_session.on 'load_urls', (urls) ->
        #
        $items = $link_items.find '.item'
        #
        for url in urls
          found = false
          $items.each ->
            $i = $ this
            if $i.attr('url') is url
              found = true
          if not found
            short_url = url.replace /http:\/\//, ''
            if short_url.length > 17
              short_url = short_url.substr(0, 15)+'...'
            $link_items.append '<div class="item" url="'+url+'"><div class="url">'+short_url+'</div><div class="button">-</div></div>'
      #
      #
      #
      # ---------
      # Thumbs
      # ------------------------------------
      #
      $text_align = $home_designer.find '.text_align .option'
      #
      card_loaded = ->
        #
        $text_align.unbind('click').click ->
          $t_a = $ this
          $t_a.make_active()
        #
        #
        $lines = $editor.find '.line'
        #
        new_active_line = ->
          #
          $active_line = $lines.filter '.active'
          #
          $line_value.val $active_line.html()
        #
        #
        $lines.click ->
          $t = $ this
          $t.make_active()
          new_active_line()
        #
        new_active_line()
        #
      #
      #
      active_theme = {}
      #
      $front_back = $home_designer.find '.front_back .option'
      $front_back.click ->
        $f_b = $ this
        $f_b.make_active()
        #
        #
        $thumbs.filter('.active').click()
        #
        side = $f_b.html()
        #
        #
        $themes.removeClass 'front back'
        $themes.addClass side
        #
        #
        $card.addClass 'collapsed'
        #
        setTimeout ->
          #
          #
          $card.addClass 'stop_animate'
          $card.removeClass 'collapsed'
          $card.addClass 'collapsed2'
          setTimeout ->
            #
            #
            $.create_card_from_theme
              height: 300
              width: 525
              theme: active_theme
              active_view: 0
              card: $all_card
              side: side
            #
            $card.removeClass 'stop_animate'
            $card.removeClass 'collapsed2'
            #
            card_loaded()
            #
          , 0
        , 500
      #
      #
      #
      io_session.on 'load_theme', (theme) ->
        #
        #
        active_theme = theme
        #
        #
        side = $front_back.filter('.active').html()
        #
        #
        unless $card.hasClass 'collapsed'
          #
          $.create_card_from_theme
            height: 300
            width: 525
            theme: theme
            active_view: 0
            card: $all_card
            side: side
          #
          card_loaded()
          #
        #
      #
      #
      #
      #
      io_session.on 'load_themes', (themes) ->
        #
        #
        for theme,i in themes
          #
          $new_thumb = $ '<div class="thumb"><div class="fg_bg" /><div class="bg_bg" /></div>'
          $new_thumb.attr
            id: theme._id
          #
          $fg_image = $ '<img class="fg" />'
          $fg_image.attr
            src: '/thumb/'+theme._id+''
          $new_thumb.append $fg_image
          #
          #
          $bg_image = $ '<img class="bg" />'
          $bg_image.attr
            src: '/thumb/'+theme._id+'/back'
          $new_thumb.append $bg_image
          #
          $themes.append $new_thumb
          #
        #
        $thumbs = $themes.find '.thumb'
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
          $thumb.make_active()
          #
          io_session.emit 'get_theme', $thumb.attr('id')
          #
          #
          #console.log id
        #
        #
        for thumb in $thumbs
          if thumb.id is active_theme_id
            $thumb = $ thumb
            #
            # Activate that theme
            $thumb.click()
            #
            # And scroll to it
            $themes.scrollTo $thumb
            #
            #
      # ------------------------------------
      # End Thumbs
      # ---------
      #
      #
      #
      $shipping_form = $ '.shipping_form'
      #
      #
      # -------
      # Quantity
      # -------
      $quantity = $shipping_form.find '.quantity .option'
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
        # And save it
        io_session.emit 'save_order_form',
          cards: $q.attr 'cards'
          cost: $q.attr 'cost'
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
      # --------------
      # Address Search
      # --------------
      $street = $shipping_form.find '.street'
      $map = $shipping_form.find '.map'
      $zip_code = $shipping_form.find '.zip_code'
      $full_address = $shipping_form.find '.full_address'
      #
      check_address_timer = 0
      maybe_check_address = ->
        $map.html 'Waiting'
        clearTimeout check_address_timer
        check_address_timer = setTimeout ->
          #
          $map.html 'Searching ...'
          #
          # 
          io_session.emit 'search_address',
            street: $street.val()
            zip_code: $zip_code.val()
          #
          #
        , 1000
      #
      $street.keyup maybe_check_address
      $zip_code.keyup maybe_check_address
      #
      load_map = (map) ->
        $new_img = $ '<img />'
        if map.full_address
          coordinates = map.latitude+','+map.longitude
          $new_img.attr 'src', '//maps.googleapis.com/maps/api/staticmap?center='+coordinates+'&markers=color:red%7Clabel:V%7C'+coordinates+'&zoom=13&size=125x110&sensor=false'
          $full_address.html map.full_address.replace /,/, '<br>'
        else
          $new_img.attr 'src', null
        #
        $map.html ''
        $map.append $new_img
      #
      io_session.on 'load_map', load_map
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
      io_session.on 'load_order_form', (order_form) ->
        if order_form
          $a_q = $quantity.filter('[cards='+order_form.cards+']')
          $a_q.make_active()
          $preview_count.html '<div class="large">'+$a_q.attr('cards')+'</div><div class="small">x</div>'
          #
          #
          if order_form.full_address
            load_map order_form
            #
            $street.val order_form.street
            $zip_code.val order_form.zip_code
            #
            #
          #
        else
          #
          $quantity.first().make_active()
        #
        #
        #
        #
        if not $thumbs
          io_session.emit 'get_themes', true
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
  amount = 10
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
                  update_radio_highlights()
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
  #
  #
  #
