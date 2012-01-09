#= require 'libs/jquery-1.7.1.js'
#= require 'libs/date'
#= require 'libs/qrcode'
#= require 'libs/scrollTo.js'
#= require 'libs/underscore.js'
#= require 'libs/jquery-ui-1.8.16.js'
#= require 'libs/jquery.colorpicker.js'
#= require 'libs/socket.io.js'
#= require 'libs/jquery.lettering.js'


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
    #
    # ----------------------------------------------
    # Images
    # ----------------------------------------------
    widthheight = settings.width+'x'+settings.height
    widthheight = 'raw' if settings.width > 525
    widthheight = '158x90' if settings.width < 158
    widthheight = '525x300' if settings.width > 158 and settings.width < 525
    #
    theme_template.images = [
      s3_id: widthheight+'/' + settings.theme.s3_id
      h: 100
      w: 100
      x: 0
      y: 0
    ]
    #
    $imgs = $my_card.find '.img'
    #
    $imgs.hide()
    #
    for pos, i in theme_template.images
      if $imgs.eq(i).length
        $img = $imgs.eq(i)
      else
        $img = $ '<img class="img" />'
        $img.appendTo $my_card
      $img.attr 'src', '//d3eo3eito2cquu.cloudfront.net/'+pos.s3_id
      $img.show().css
        position: 'absolute'
        top: pos.y/100 * settings.height
        left: pos.x/100 * settings.width
        width: (pos.w/100 * settings.width) + 'px'
        height: (pos.h/100 * settings.height) + 'px'
    #
    # Set the card background
    $my_card.css
      background: '#FFF'
      height: settings.height
      width: settings.width
    # ----------------------------------------------
    # END Images
    # ----------------------------------------------
    #
    #
    #
    $lines = $my_card.find '.line'
    #
    #
    #
    # ----------------------------------------------
    # Hack For Back Side
    # ----------------------------------------------
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
      stylify_a_line = ($li, n_l, c_w, pos) ->
        #
        #
        $li.show().css
          position: 'absolute'
          top: pos.y/100 * settings.height
          left: n_l
          width: c_w
          fontSize: (pos.h/100 * settings.height) + 'px'
          lineHeight: (pos.h/100 * settings.height) + 'px'
          fontFamily: pos.font_family
          textAlign: pos.text_align
          color: '#'+pos.color
        #
        #
        $li.css
          width: 'auto'
        #
        n_w = $li.width()
        if pos.text_align is 'right'
          n_l = n_l + c_w - n_w
        if pos.text_align is 'center'
          n_l = n_l + (c_w - n_w)/2
        #
        #
        $li.css
          left: n_l
          width: n_w
      #
      #
      for pos,i in theme_template.lines
        #
        $li = $lines.eq(i)
        n_l = pos.x/100 * settings.width
        c_w = pos.w/100 * settings.width
        #
        #
        do ($li, n_l, c_w, pos) ->
          #
          if not $li.length
            $li = $ '<div class="line" />'
            $li.appendTo $my_card
            #
            $li.html $.line_copy[i]
            setTimeout ->
              stylify_a_line($li, n_l, c_w, pos)
            , 500
            #
          else
            $li.html $.line_copy[i]
            stylify_a_line $li, n_l, c_w, pos
          #
        #
        #
      #
      #
    # ----------------------------------------------
    # END Hack For Back Side
    # ----------------------------------------------
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
    $all_card = $ '.card'
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
              $editor.find('.line:first').click()
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
    #
    #
    #
    #
    $upload_button = $home_designer.find '.upload_button'
    $upload_form = $home_designer.find '.upload_form'
    $upload_input = $upload_form.find 'input[type=file]'
    #
    $upload_button.click -> $upload_input.click()
    $upload_input.change -> $upload_form.submit()
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
      $images = $editor.find '.img'
      $qr = $editor.find '.qr'
      $lines = $editor.find '.line'
      #
      new_active = ->
        #
        $active_line = $lines.filter '.active'
        #
        if $active_line.length
          #
          $line_value.val $active_line.html()
          setTimeout ->
            $line_value.focus().select()
          , 0
          #
          $areas.eq(0).make_active()
        else
          $areas.eq(0).removeClass 'active'
        #
        #
        #
        $active_qr = $qr.filter '.active'
        #
        if $active_qr.length
          #
          $areas.eq(1).make_active()
          #
        else
          $areas.eq(1).removeClass 'active'
        #
        #
        $active_image = $images.filter '.active'
        #
        if $active_image.length
          #
          $areas.eq(2).make_active()
        else
          $areas.eq(2).removeClass 'active'

      #
      #
      remove_focus_event = (e) ->
        $t = $ e.target
        $c = $t.closest('.controls').andSelf().filter('.controls')
        $e = $t.closest('.card.editor').andSelf().filter('.card.editor')
        unless $c.length or $e.length
          $editor.find('.active').removeClass 'active'
          $body.unbind 'click', remove_focus_event
          new_active()
      #
      add_remove_focus_event = ->
        $body.bind 'click', remove_focus_event

      #
      #
      #
      #
      #
      #
      #
      $lines.add($images).add($qr).click (e) ->
        $t = $ this
        $t.make_active()
        new_active()
        add_remove_focus_event()
      #
      new_active()
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
      setTimeout ->
        #
        #
        #$thumbs.filter('.active').click()
        #
        side = $f_b.html()
        #
        #
        $fg = $thumbs.add($all_card).find '.fg'
        $bg = $thumbs.add($all_card).find '.bg'
        #
        #
        $first = $fg
        $second = $bg
        #
        if side is 'front'
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
            $.ajax
              url: '/get-theme'
              data: JSON.stringify
                theme_id: $thumb.attr('id')
              success: (results) ->
                #
                active_theme = results.theme
                #
                #
                side = $front_back.filter('.active').html()
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
                    side: 'front'
                  #
                  $.create_card_from_theme
                    height: 300
                    width: 525
                    theme: theme
                    active_view: 0
                    card: $bg
                    side: 'back'
                #
                card_loaded()
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
              $themes.scrollTo $thumb,
                offset: 
                  left: 0
                  top: -20
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
      $.ajax
        url: '/save-order-form'
        data: JSON.stringify
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
        $new_img.attr 'src', '//maps.googleapis.com/maps/api/staticmap?center='+coordinates+'&markers=color:red%7Clabel:V%7C'+coordinates+'&zoom=13&size=125x110&sensor=false'
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
      url: '/get-session'
      success: (results) ->
        #
        if results.session and results.session.order_form
          o_f = results.session.order_form
          $a_q = $quantity.filter('[cards='+o_f.cards+']')
          $a_q.make_active()
          $preview_count.html '<div class="large">'+$a_q.attr('cards')+'</div><div class="small">x</div>'
          #
          #
          if o_f.full_address
            load_map o_f
            #
            $street.val o_f.street
            $zip_code.val o_f.zip_code
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
          get_themes()
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
