#= require 'libs/jquery-1.6.2.js'
#= require 'libs/jquery-ui-1.8.16.min.js'
#= require 'date'
#= require 'libs/qrcode'



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
$.line_copy = [
  'Jimbo jo Jiming'
  'Banker Extraordinaire'
  'Cool Cats Cucumbers'
  '57 Bakers, Edwarstonville'
  '555.555.5555'
  'New York'
  'Apt. #666'
  'M thru F - 10 to 7'
  'fb.com/my_facebook'
  '@my_twitter'
]

random_strings = 'taameer73,Heesoh750,hiyit510,tuhaat140,Caaran74,lehof520,caniih190,Hiideer380,Doret53,yyywuut30,Febaad8,tootool61,huudiiz15,posaay690,Saakec590,tiloop930,lunad43,saatiim880,rolat70,mawas41,hidum17,baget520,Neekiir460,losiin220,leeleh45,Harees970,Cafeer440,neepat54,sojag760,ciqueen360,niifaat170,quetuuf470,tiimet66,deeros280,geeceel12,Taasow82,Fadoof87,Dodet720,riiteg15,jiitaaf25,Fujah620,hudon52,Sonit76,ceefoon680,sooneet88,ceesiis61,Tewiit520,tiiteh120,Cetiis72,Rylah25,reehyb340,Yerex67,QUiiwit10,satar530,Metew2,Leseh72,Leeheeb130,Giiliiw880,weetoog11,Cisin530,Juutih360,feseen310,Toopar73,Catet160,neejes690,Tyfeed21,Tatiic420,Watook720,Haawyc11,Motuuqu490,haayaah29,duufeec880,lityl770,moocuun88,behed21,hateeh89,Gosas4,cenood510,teneeh880,Lyyfeen970,pucun630,Liitec880,Teetiiqu110,Tageed38,zagaah480,neeheer87,hisig33,lasas450,tequot80,Dahiin840,Pubuqu860,Totoot79,Soonoom41,Faawut860,Heemaaqu15,hirin330,Leteen40,Seemeer790,faaween0,Yeesas680'.split ','








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
  $my_card = $ '<div class="card"><div class="qr"><div class="background" /></div></div>'
  #
  $my_card.data 'theme', settings.theme
  #
  $my_qr = $my_card.find('.qr')
  #
  $my_qr.html '<img src="/qr/' + theme_template.qr.color1 + '/?cards.ly" height=' + theme_template.qr.h/100 * settings.height + ' width=' + theme_template.qr.w/100 * settings.width + ' \/><div class="background" \/> '
  #
  $my_qr_bg = $my_qr.find '.background'
  #
  $my_qr.css
    position: 'absolute'
    top: theme_template.qr.y/100 * settings.height
    left: theme_template.qr.x/100 * settings.width
    zIndex: 200
  $my_qr.find('img').css
    position: 'absolute'
    zIndex: 150
  $my_qr_bg.css
    zIndex: 140
    position: 'absolute'
    'border-radius': theme_template.qr.radius+'px'
    height: theme_template.qr.h/100 * settings.height
    width: theme_template.qr.w/100 * settings.width
    background: '#' + theme_template.qr.color2
  $my_qr_bg.fadeTo 0, theme_template.qr.color2_alpha
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
    background: 'url(\'//d3eo3eito2cquu.cloudfront.net/'+settings.width+'x'+settings.height+'/' + theme_template.s3_id + '\')'
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
 * 
 * Generic Tooltip function
 * 
 * - does a little tooltip dealy bob on any element
 *
 * - usually used for form inputs
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
    tooltip.stop(true,true).fadeIn().delay(4000).fadeOut()
    $t.data 'tooltip', tooltip
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
  # FIRST, some redirect
  #
  if document.location.href.match /#bypass_splash/i
    $.cookie 'bypass_splash', true
  #
  # Redirect non compatible browsers *IMMEDIATELLY*
  if $.browser.msie and parseInt($.browser.version, 10)<9 and not document.location.href.match(/splash/) and not $.cookie 'bypass_splash'
      document.location.href = '/old-browser'
  #
  #
  $error = $ '.error'
  if $error.length
    $('html,body').animate
      scrollTop: $error.offset().top-50
      500
      ->
        $error.stop(true,true).delay(300).fadeOut().fadeIn().fadeOut().fadeIn().fadeOut().fadeIn()



  #################################################################
  #
  # MENU
  #
  #
  ###
  Profile MENU in the TOP RIGHT
  Thing that shows a drop down
  ###
  $a = $ '.account_link'
  $am = $a.find '.account_menu'
  $body = $(document)
  $('.small_nav li').live 'mouseenter', ->
    $(this).addClass 'hover'
  $('.small_nav li').live 'mouseleave', ->
    $(this).removeClass 'hover'
  close_menu = (e) ->
    $t = $ e.target
    if $t.closest('.account_link').length
      $a = $t.closest('li').find 'a'
      document.location.href = $a.attr 'href'
    else
      $a.removeClass 'click'
      $am.slideUp(150)
      $a.one 'click', expand_menu
      $body.unbind 'click', close_menu
    false
  expand_menu = ->
    $am.slideDown(150)
    $a.addClass 'click'
    $body.bind 'click', close_menu
    false
  $a.one 'click', expand_menu
  #
  #
  # END MENU
  #
  #################################################################








  #################################################################
  #
  # HELP OVERLAYS
  #
  #
  $('.help_container').each ->
    $t = $ this
    $overlay = $t.find '.help_overlay'
    $close = $t.find '.help_close'
    $trigger = $t.find '.help_trigger'
    do_close = ->
      $overlay.hide()
      $close.hide()
      $trigger.show()
    do_show = ->
      $overlay.show()
      $close.show()
      $trigger.hide()
    $overlay.click do_close
    $close.click do_close
    $trigger.click do_show
  #
  #
  # END HELP OVERLAYS
  #
  #################################################################









  #
  #
  # Path we'll use a few places, it's just the page we're on now, yeah?
  path = document.location.href.replace /http:\/\/[^\/]*/ig, ''
  #
  #
  #
  #
  #
  # Get Started Button Scroll
  $('.design_button').click ->
    if $('.home_designer').length
      $('html,body').animate
        scrollTop: $('.home_designer').offset().top-100
        500
        ->
          $('.home_designer .line:first').click()
    else
      document.location.href='/buy'
    false




  #################################################################
  #
  # LOGIN
  #
  # Successful Login Function
  successful_login = ->
    if path == '/login'
      document.location.href = '/admin'
    else
      $.load_loading {}, (loading_close) ->
        $.ajax
          url: '/get-user'
          success: (user) ->
            if path is 'login'
              document.location.href = '/'
            else
              loading_close()
              if user.err
                $.load_alert
                  content: user.err
              else
                $s = $ '.signins' 
                $s.html '<p>Congratulations ' + (user.name or user.email) + ', you are now connected to cards.ly</p><div class="check"><ul><li class="do_send_confirm"><input type="checkbox" id="do_send_confirm" checked="checked"><label for="do_send_confirm">Send a confirmation email</label></li><li class="do_send_shipping"><input type="checkbox" id="do_send_shipping" checked="checked"><label for="do_send_shipping">Send a shipping receipt</label></li><li class="email_to_send"><label for="email_to_send">To:</label><input name="email_to_send" id="email_to_send" placeholder="my@email.com" value="' + (user.email or '') + '"></li></ul></div>'
                $('.small_nav .login').replaceWith '<li class="account_link"><a href="/settings">' + (user.name or user.email) + '<div class="gear"><img src="/images/buttons/gear.png"></div></a><ul class="account_menu"><li><a href="/settings">Settings</a></li><li><a href="/logout">Logout</a></li></ul></li>'
              #
              #
          error: (err) ->
            loading_close()
            $.load_alert
              content: 'Our apologies. A server error occurred.'
  #
  #
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
  #
  #
  #
  #
  #Regular Login
  $('.login_form').submit ->
    $.load_loading {}, (loading_close) ->
      $.ajax
        url: '/login'
        data: JSON.stringify
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
  # END LOGIN
  #
  #################################################################




  #################################################################
  #
  #
  # New ACCOUNT Creation
  #
  #
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
                url: '/create-user'
                data: JSON.stringify
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
            url: '/check-email'
            data: JSON.stringify
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
  #
  # END New Account
  #
  #################################################################










  #################################################################
  #
  # FEEDBACK BUTTON STUFF
  #
  #
  $feedback_a = $ '.feedback a'
  $feedback_a.mouseover () ->
    $feedback = $ '.feedback'
    if $.browser.msie and parseInt($.browser.version, 10)<9
      console.log 'Do something for IE7 here'
    else
      $feedback.stop(true,false).animate
        right: '-37px'
        ,250
  $feedback_a.mouseout () ->
    $feedback = $ '.feedback'
    if $.browser.msie and parseInt($.browser.version, 10)<9
      console.log 'Do something for IE7 here'
    else
      $feedback.stop(true,false).animate
        right: '-45px'
        ,250
  #
  #
  #
  #
  #Feedback Button
  $email_text = $ '.hidden_email'
  console.log $email_text.text()
  $feedback_a.click (e) ->
    e.preventDefault()
    $.load_modal
      content: '<div class="feedback_form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback_text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email"cols="40" value="'+($email_text.text())+'"></p></div>'
      width: 400
      height: 300
      buttons: [
        label: 'Send Feedback'
        action: (form_close) ->
          #Close the window
          form_close()
          $.load_loading {}, (loading_close) ->
            $.ajax
              url: '/send-feedback'
              data: JSON.stringify
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
  #
  # END FEEDBACK
  #
  #################################################################







  
  #################################################################
  #
  # CATEGORY SELECTION
  #
  # (used on both admin and order form)
  #
  # The floaty guy behind the gallery selection
  $gs = $ '.gallery_select'
  $gs.css
    left: -220
    top: 0
  $('.category .card').live 'click', () ->
    $t = $ this
    $('.card').removeClass 'active'
    $t.addClass('active')
    if $gs.offset().top == $t.offset().top-5
      $gs.animate
        left: $t.offset().left-5
      ,300
    else
      $gs.stop(true,false).animate
        top: $t.offset().top-5
      ,300,'linear',() ->
          $gs.animate
            left: $t.offset().left-5
          ,300,'linear'
  #
  # 
  # Category Expand/Collapse
  $('.category h4').live 'click', () ->
    $t = $ this
    $c = $t.closest '.category'
    $g = $c.find '.cards'
    $a = $ '.category.active'
    if !$c.hasClass 'active'
      $a.removeClass('active')
      $a.find('.cards').show().slideUp 400
      $gs.hide()
      $c.find('.cards').slideDown 400, ->
        $gs.show()
        $c.find('.card:first').click()
      $c.addClass('active')
  #
  #
  #################################################################







  #################################################################
  #
  #
  # BUTTONS?
  #
  # Buttons everywhere need hover and click states
  $('.button').live 'mouseenter', ->
    $(this).addClass 'hover'
  .live 'mouseleave', ->
    $(this).removeClass 'hover'
  .live 'mousedown', ->
    $(this).addClass 'click'
  .live 'mouseup', ->
    $(this).removeClass 'click'
  #
  # END BUTTONS
  #
  #################################################################











  

  # Grab all our jQuery guys that we're going to re use
  # (this is effectively instantiating classes)
  $designer = $ '.home_designer'
  $categories = $ '.categories'
  $card = $designer.find '.card'
  $qr = $card.find '.qr'
  $qr_bg = $qr.find '.background'
  $lines = $card.find '.line'
  #
  #
  $view_buttons = $ '.views .option'
  #
  #
  # The form stuff at the bottom
  $quantity = $('.quantity')
  $shipping_method = $('.shipping_method')
  $address = $('.address')
  $address_result = $('.address_result')
  $city = $('.city')
  #
  #
  $body = $ document
  #
  #
  # Set some constants
  $active_theme = false
  active_theme = {}
  active_view = 0
  card_height = 0
  card_width = 0
  card_inner_height = 0
  card_inner_width = 0
  update_card_size = ->
    card_height = $card.outerHeight()
    card_width = $card.outerWidth()
    card_inner_height = $card.height()
    card_inner_width = $card.width()
  update_card_size()
  #$qr.prep_qr()













  ##############
  #
  # LOADING the themes
  #
  if $categories.length
    all_themes = []
    load_theme_thumbnails = ->
      for theme in all_themes
        #
        #
        #
        $my_card = $.create_card_from_theme
          theme: theme
          active_view: active_view
        #
        #
        if active_theme._id and theme._id is active_theme._id
          $active_theme = $my_card
        #
        # Push the whole thing to categories
        $.add_card_to_category $my_card, theme
      #
      #
      # Restore active theme
      if $active_theme
        $active_theme.closest('.category').addClass('active')
        $active_theme.click()
      else
        $categories.find('.category:first h4').click()
      #
      #
      #
      #
      #
      $lines.each (i) ->
        update_cards i, $(this).html()
    #
    #
    #
    $.ajax
      url: '/get-themes'
      success: (all_data) ->
        all_themes = all_data.themes
        $categories.html ''
        #
        #
        # Restore active view
        $active_view = $ '.active_view'
        if $active_view.html() and $active_view.html() isnt ''
          active_view = $active_view.html()
        $view_buttons.filter('.active').removeClass 'active'
        $view_buttons.filter(':eq(' + active_view + ')').addClass 'active'
        #
        load_theme_thumbnails()
        #
        #
        active_theme._id = $('.active_theme_id').html()
        #
      #
      #
      error: ->
        $.load_alert
          content: 'Error loading themes. Please try again later.'
    $('.category .card').live 'click', () ->
      $t = $ this
      theme = $t.data 'theme'
      if theme
        load_theme theme
        history = [theme]
        set_timers()
  #
  #
  #
  # END The Themes
  #
  #
  ##############









  ##################################################################
  #
  # THEME SELECTING AND SWITCHING
  #
  #
  # - load_theme loads the selected theme in the main card designer area
  #
  # - timer events save form fields periodically to server
  #
  #
  load_theme = (theme) ->
    #
    # Set Constants
    theme_template = theme.theme_templates[active_view] or theme.theme_templates[0]
    # 
    #
    #
    # set this theme as the active_theme
    active_theme = theme
    #
    #
    # Card Background
    if theme_template.s3_id
      $card.css
        background: '#FFFFFF url(\'//d3eo3eito2cquu.cloudfront.net/525x300/' + theme_template.s3_id + '\')'
    else
      $card.css
        background: '#FFFFFF'
      $card.css
        height: 280
        width: 505
        padding: 10
        margin: 0
      update_card_size()
    #
    #
    $qr.hide()
    $lines.hide()
    #
    #
    #
    # Show the qr code and set it to the right place
    $qr.show().css
      top: theme_template.qr.y/100 * card_height
      left: theme_template.qr.x/100 * card_width
    $qr.find('canvas').css
      height: theme_template.qr.h/100 * card_height
      width: theme_template.qr.h/100 * card_height
    $qr_bg.css
      'border-radius': theme_template.qr.radius+'px'
      height: theme_template.qr.h/100 * card_height
      width: theme_template.qr.w/100 * card_width
      background: '#'+theme_template.qr.color2
    $qr_bg.fadeTo 0, theme_template.qr.color2_alpha
    $qr.qr
      color: theme_template.qr.color1
      height: theme_template.qr.h/100 * card_height
      width: theme_template.qr.h/100 * card_height
    #
    #
    # Move all the lines and their shit
    for pos,i in theme_template.lines
      $li = $lines.eq i
      $li.show().css
        top: pos.y/100 * card_height
        left: pos.x/100 * card_width
        width: (pos.w/100 * card_width) + 'px'
        height: (pos.h/100 * card_height) + 'px'
        fontSize: (pos.h/100 * card_height) + 'px'
        lineHeight: (pos.h/100 * card_height) + 'px'
        fontFamily: pos.font_family
        textAlign: pos.text_align
        color: '#'+pos.color
    #
    #
    # For the home page, show the selected card at the bottom
    $active_card = $.create_card_from_theme
      theme: active_theme
      height: 300
      width: 525
      active_view: active_view
    $('.my_card').children().remove()
    $('.my_card').append $active_card
    $active_card.find('.qr canvas').css
      left: 0
      margin: 0
    #
    #
    #
    ###
    TODO

    - this probably doesn't need to update every time. Could make page faster not doing this.
    ###
    #
    #
    $lines.each (i) ->
      update_cards i, $(this).html()
  #
  #
  #
  #
  input_timer = 0
  set_timers = ->
    clearTimeout input_timer
    input_timer = setTimeout ->
      #
      # Find the values of quantiy and speed
      $q = $('.quantity input:checked')
      $s = $('.shipping_method input:checked')
      #
      #
      # Find the values for the card lines from the main designer
      values = $.makeArray $lines.map -> 
        $(this).html()
      #
      #
      $.ajax
        url: '/save-form'
        data: JSON.stringify
          values: values
          active_view: active_view
          active_theme_id: active_theme._id
          quantity: $q.val()
          shipping_method: $s.val()
      false
    ,1000
  #
  ###
  Update Cards

  This is used each time we need to update all the cards on the home page with the new content that's typed in.
  ###
  update_cards = (rowNumber, value) ->
    $('.categories .card').add('.order_total .card').each -> 
      $t = $ this
      $t.find('.line:eq('+rowNumber+')').html value
  #
  #
  #
  # Form Fields
  shift_pressed = false
  $lines.each (i) ->
    $t = $ this
    $t.data 'timer', 0
    
    $t.click -> 
      if i is 6
        $view_buttons.filter(':last').click()
      style = $t.attr 'style'
      $input = $ '<input class="line" />'
      $input.attr 'style', style
      $input.val $t.html()
      $t.after $input
      $t.hide()
      $input.focus().select()
      $input.keydown (e) ->
        if e.keyCode is 16
          shift_pressed = true
        if e.keyCode is 13 or e.keyCode is 9
          e.preventDefault()
          $next = $t.nextAll('div:visible:first')
          if shift_pressed
            $next = $t.prev()
            if not $next.length
              $next = $lines.filter(':visible:last')
          else
            ###
            Uncomment this to allow entering to 10 mode
            if i is 5
              $next = $t.nextAll('div:first')
            ###
            if not $next.length
              $next = $lines.filter(':first')
          $next.click()
          return false
      $input.keyup (e) ->
        if e.keyCode is 16
          shift_pressed = false
        update_cards i, this.value
        $t.html this.value
        set_timers()

      remove_input = (e) ->
        $target = $ e.target
        if $target[0] isnt $t[0] and $target[0] isnt $input[0]
          $body.unbind 'click', remove_input
          $input.remove()
          $t.show()
      $body.bind 'click', remove_input
  #
  #
  #
  #
  #
  # END THEME SELECTION
  #
  #
  #
  #
  #
  #############################################################
















  #############################################################
  #
  #
  # ORDER FORM STUFF
  #
  #
  #
  #
  #
  # Hide the form
  $existing_payment = $ '.existing_payment'
  #$existing_payment.hide()

  $existing_payment.find('.button').click ->
    $existing_payment.hide()
    $('.order_total form').show()
    $('.use_existing_payment').show().unbind().click ->
      $existing_payment.show()
      $('.order_total form').hide()
      $(this).hide()
      false
    false
  if $existing_payment.length
    $('.order_total form').hide()
  ###
  SAMURAI
  $existing_payment.find('.button').click ->
    $existing_payment.remove()
    $('.order_total form').show()
    false
  if $existing_payment.length
    $('.order_total form').hide()
  ###
  #
  #
  #
  #
  #
  #
  ###
  # Radio Button Clicking Stuff
  ###
  #
  amount = 10
  #
  $('.quantity li').click ->
    $t = $ this
    $t.closest('li').andSelf().find('input').attr('checked',true).trigger 'change'
    false
  #
  # Radio Select
  $('.quantity input,.shipping_method input').bind 'change', () ->
    $q = $('.quantity input:checked')
    $s = $('.shipping_method input:checked')
    #
    # Set Class
    $('.quantity li').removeClass 'active'
    $q.closest('li').addClass 'active'
    #
    #
    # Set Class
    $('.shipping_method li').removeClass 'active'
    $s.closest('li').addClass 'active'
    #
    #
    amount = ($q.val()*1) + ($s.val()*1)
    $('.order_total .price').html '$' + amount
    #
    #
    #
    set_timers()
  $('.quantity input,.shipping_method input').trigger 'change'
  #
  #
  address_timer = 0
  set_address_timer = ->
    clearTimeout address_timer
    address_timer = setTimeout ->
      address = $address.val()
      city = $city.val()
      if address is ''
        $address.show_tooltip
          message:'Please enter a street address'
      else if city is ''
        $address.data('tooltip').stop().hide() if $address.data 'tooltip'
        $city.show_tooltip
          message:'Please enter a city or zip code'
      else
        $address.data('tooltip').stop().hide() if $address.data 'tooltip'
        $city.data('tooltip').stop().hide() if $city.data 'tooltip'
        $address_result.html 'Searching for real address ...'
      
        $.ajax
          url: '/find-address'
          data: JSON.stringify
            address: address
            city: city
          success: (result) ->
            if result.full_address
              $address_result.html result.full_address
            else
              $address_result.html 'Not found - try again?'
          error: ->
            $address_result.html address+'<br>'+city

    ,1000
  #
  $address.keyup set_address_timer
  $city.keyup set_address_timer
  #
  #
  #
  # Window and Main Card to use later
  $win = $ window
  $mc = $ '.home_designer'
  #
  #
  #
  #
  #
  #
  $view_buttons.click ->
    $t = $ this
    $view_buttons.filter('.active').removeClass 'active'
    $t.addClass 'active'
    #
    index = $t.prevAll().length
    active_view = index
    #
    #
    $('.category .cards').html ''
    load_theme_thumbnails()
    set_timers()
  ###
  Shopping Cart Stuff
  ###
  #
  # Default Item Name
  item_name = '100 cards'
  #
  #
  if env is 'development'
    Stripe.setPublishableKey 'pk_ZHhE88sM8emp5BxCIk6AU1ZFParvw'
  else
    Stripe.setPublishableKey 'pk_5U8jx27dPrrPsm6tKE6jnMLygBqYg'
  #
  # Test
  #
  # Checkout button action, default error for now.
  $('.checkout').click () ->
    $.load_loading {}, (loading_close) ->

        $.ajax
          url: '/validate-purchase'
          success: (result) ->
            if result.error
              loading_close()
              if result.error is 'Please sign in'
                $s = $ '.signins' 
                $('html,body').animate
                  scrollTop: $s.offset().top-50
                  500
                setTimeout ->
                  $s.stop(true,true).delay(300).fadeOut().fadeIn().fadeOut().fadeIn().fadeOut().fadeIn()
                  $s.show_tooltip
                    message: 'Please sign in or create an account.'
                ,500
              if result.error is 'Hey Uncle Jesse, is that you?'
                $('html,body').animate
                  scrollTop: $mc.offset().top
                  500
                setTimeout ->
                  $.load_alert
                    content: result.error+'.<p>Please try clicking on the text on this card.'
                ,500
              else
                $.load_alert
                  content: result.error
            else if result.success
              console.log 'AMOUNT: ', amount
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
                    confirm_email: $('.do_send_confirm input').is(':checked')
                    shipping_email: $('.do_send_shipping input').is(':checked')
                    email: $('.email_to_send input').val()
                  success: (result) ->
                    console.log result
                    if result.err
                      loading_close()
                      $.load_alert
                        content: 'We tried that, and the credit card processor told us:<p><blockquote>' + result.err + '</blockquote></p>'
                    else
                      console.log result
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
              if $('.card_number').val() and $('.cvv').val()
                #
                # Create a token based on the card number perhaps
                Stripe.createToken
                    number: $('.card_number').val()
                    cvc: $('.cvv').val()
                    exp_month: $('.card_expiry_month').val()
                    exp_year: $('.card_expiry_year').val()
                , amount, (status, response) ->
                  console.log status, response
                  if status is 200
                    token = response.id
                    load_final()
                  else
                    loading_close()
                    $.load_alert
                      content: 'We tried that, and the credit card processor told us:<p><blockquote>' + response.error.message + '</blockquote></p>'
              #
              #
              else if $('.existing_payment:visible').length
                load_final()
              #
              #
              else
                $.load_alert
                  content: 'Please enter a credit card'
              ###

              THIS IS THE SAMURAI INTEGRATION

              if $('.existing_payment').length
                document.location.href = '/thank-you'
              else
                $('.order_total form').submit()
              ###
            else
              loading_close()
              $.load_alert
                content: 'Our apoligies, something went wrong, please try again later'
          error: ->
            loading_close()
            $.load_alert
              content: 'Our apoligies, somethieng went wrong, please try again later'
    false

  #
  #
  #
  #
  # END ORDER FORM STUFF
  #
  #############################################################







