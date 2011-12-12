#= require 'libs/jquery-1.6.2.js'
#= require 'libs/jquery-ui-1.8.16.min.js'
#= require 'date'
#= require 'libs/qrcode'
#= require 'libs/scrollTo.js'
#= require 'libs/underscore.js'



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
    background: 'url(\'//d3eo3eito2cquu.cloudfront.net/'+settings.width+'x'+settings.height+'/' + settings.theme.s3_id + '\')'
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
jQuery.fn.sortElements = (->
  sort = [].sort
  (comparator, getSortable) ->
    getSortable = getSortable or ->
      this

    placements = @map(->
      sortElement = getSortable.call(this)
      parentNode = sortElement.parentNode
      nextSibling = parentNode.insertBefore(document.createTextNode(""), sortElement.nextSibling)
      ->
        throw new Error("You can't sort elements if any one is a descendant of another.")  if parentNode is this
        parentNode.insertBefore this, nextSibling
        parentNode.removeChild nextSibling
    )
    sort.call(this, comparator).each (i) ->
      placements[i].call getSortable.call(this)
)()

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


  ###################################################################
  
  #
  # Header Navigation
  #
  ###
  $b = $('.header').find 'navigation'
  $body = $(document)
  $('.navigation li').live 'mouseenter', ->
    $(this).addClass 'hover'
  $('.navigation li').live 'mouseleave', ->
    $(this).removeClass 'hover'
  ###
  $navigation = $ '.navigation'
  $navigation.ready ->
    page = window.location.href.split("/")[3]
    $navigation.find('a[href$='+page+']:first').closest('li').addClass('current_nav')
    $navigation.find('li').hover ->
      $(this).addClass 'hover'
    , ->
      $(this).removeClass 'hover'
    .click (e) ->
      $a = $(this).find 'a'
      if $a.length > 0
        e.preventDefault()
        document.location.href = $a.attr 'href'


  
  ###################################################################

  #################################################################
  #
  # HELP OVERLAYS
  #
  #
  $all_help = $('.help_container')
  $overlay = $all_help.find '.help_overlay'
  $close = $all_help.find '.help_close'
  $trigger = $all_help.find '.help_trigger'
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
  #
  #
  #
  # Get Started Button Scroll
  $('.design_button').click ->
    if $('.home_designer').length
      $('html,body').animate
        scrollTop: $('.home_designer').closest('.section').offset().top-30
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
    if not $('.home_designer').length
      document.location.href = '/'
    else
      $.load_loading {}, (loading_close) ->
        $.ajax
          url: '/get-user'
          success: (user) ->
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
        label: 'Sign In'
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
    setTimeout ->
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
    , 0
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
        ###
        
        TODO


        TODO


        TODO


        TODO

        Pull lots of settings from server and re-click them

        ###
        #
        #
        #
        active_theme._id = $('.active_theme_id').html()
        #
        #
        load_theme_thumbnails()
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
  update_preview_card_at_bottom = ->
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
    $lines.each (i) ->
      update_cards i, $(this).html()
  #
  #
  #
  load_theme = (theme) ->
    #
    # Set Constants
    theme_template = theme.theme_templates[active_view] or theme.theme_templates[0]
    # 
    #
    # set this theme as the active_theme
    active_theme = theme
    #
    #
    # Card Background
    if theme.s3_id
      $card.css
        background: '#FFFFFF url(\'//d3eo3eito2cquu.cloudfront.net/525x300/' + theme.s3_id + '\')'
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
    update_preview_card_at_bottom()
    #
    #
    #
    if theme.category is 'My Own'
      show_advanced()
    else
      hide_advanced()
    #
    #
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
  # Prevent Backspace
  $('body').keydown (e) ->
    if e.keyCode is 8
      $t = $ e.target
      if not $t.closest('input').andSelf().filter('input').length
        if not $t.closest('textarea').andSelf().filter('textarea').length
          e.preventDefault()
  #
  # Form Fields
  shift_pressed = false
  $lines.each (i) ->
    $t = $ this
    $t.data 'timer', 0
    
    $t.click -> 
      if $('.tab_button .active').html() is 'Text'
        $t.addClass 'active'
        add_buttons_to_active()
      else if not $t.hasClass 'active'
        style = $t.attr 'style'
        $input = $ '<input class="line" />'
        $delete_button = $ '<div class="button gray small">X</div>'
        $delete_button.css
          width: 20
          height: $t.height()
          lineHeight: $t.height()+'px'
          position: 'absolute'
          top: parseInt($t.css('top'))-5
          left: parseInt($t.css('left'))+$t.width()+10
        $input.attr 'style', style
        $input.val $t.html().replace /&nbsp;/g, ' '
        tt = Math.round $t.offset().top/3
        tl = Math.round $t.offset().left/3
        $t.after $input
        $input.after $delete_button
        $t.hide()
        #
        #
        $delete_button.click (e) ->
          $input.val ''
          update_value()
          setTimeout ->
            go_to_next()
          , 0
        #
        #
        #
        update_value = ->
          update_cards i, $input[0].value.replace /( )/g, '&nbsp;'
          $t.html $input[0].value.replace /( )/g, '&nbsp;'
          set_timers()
        #
        #
        #
        go_to_next = ->
          $others = $t.siblings('div:visible:not(.button)')

          $next = false
          $a = false
          $b = false
          $c = false
          $others.each ->
            $a = $ this
            at = Math.round $a.offset().top/3
            al = Math.round $a.offset().left/3

            if shift_pressed
              if (at is tt and al < tl) or at < tt
                $b = $a if not $b
                bt = Math.round $b.offset().top/3
                bl = Math.round $b.offset().left/3
                if (at is bt and al > bl) or at > bt
                  $b = $a 
              $c = $a if not $c
              ct = Math.round $c.offset().top/3
              cl = Math.round $c.offset().left/3
              if (at is ct and al > cl) or at > ct
                $c = $a
            else
              if (at is tt and al > tl) or at > tt
                $b = $a if not $b
                bt = Math.round $b.offset().top/3
                bl = Math.round $b.offset().left/3
                if (at is bt and al < bl) or at < bt
                  $b = $a
              $c = $a if not $c
              ct = Math.round $c.offset().top/3
              cl = Math.round $c.offset().left/3
              if (at is ct and al < cl) or at < ct
                $c = $a
          if $b
            $b.click()
          else
            $c.click()
        #
        #
        #
        $input.focus().select()
        $input.keydown (e) ->
          if not e
            e = 
              keyCode: 13
          if e.keyCode is 16
            shift_pressed = true
          if e.keyCode is 13 or e.keyCode is 9
            e.preventDefault()
            #
            #
            go_to_next()
        $input.keyup (e) ->
          if e.keyCode is 16
            shift_pressed = false
          if e.keyCode is 13 or e.keyCode is 9
            e.preventDefault()
          update_value()

        remove_input = (e) ->
          $target = $ e.target
          if $target[0] isnt $t[0] and $target[0] isnt $input[0] and $target[0] isnt $delete_button[0]
            $body.unbind 'click', remove_input
            $input.remove()
            $delete_button.remove()
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
  # ADVANCED CARD DESIGNER
  #
  #
  # Helper Function for getting the position in percentage from an elements top, left, height and width
  get_position = ($t) ->
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
  #
  save_pos_and_size = ->
    $visible_lines = $lines.filter ':visible'
    $visible_lines.each ->
      $v = $ this
      pos = get_position $v
      index = $v.prevAll().length
      active_theme.theme_templates[active_view].lines[index].h = pos.h
      active_theme.theme_templates[active_view].lines[index].w = pos.w
      active_theme.theme_templates[active_view].lines[index].x = pos.x
      active_theme.theme_templates[active_view].lines[index].y = pos.y
    set_my_theme_save_timers()
  #
  #
  #
  card_o = $card.offset()
  card_w = $card.outerWidth()
  card_h = $card.outerHeight()
  #
  #
  add_buttons_to_active = ->
    #
    remove_buttons_from_active()
    #
    $active_lines = $lines.filter '.active'
    #
    if $active_lines.length
      #
      $active_lines = _($active_lines).sortBy (a) ->
        $(a).offset().top
      #
      $first = $($active_lines[0])
      $last = $(_($active_lines).last())
      #
      #
      $font_decrease = $ '<div class="font_decrease">-</div>'
      $card.append $font_decrease
      #
      $font_increase = $ '<div class="font_increase">+</div>'
      $card.append $font_increase
      #
      #
      position_these_buttons = ->
        #
        $font_decrease.css
          top: $last.offset().top - card_o.top + $last.outerHeight()
          left: $last.offset().left + $last.outerWidth() - 30 - card_o.left
        $font_increase.css
          top: $first.offset().top - 20 - card_o.top
          left: $first.offset().left + $first.outerWidth() - 30 - card_o.left
        #
      #
      #
      position_these_buttons()
      #
      #
      #
      #
      $active_lines = $lines.filter '.active'
      #
      # And finally, the events for that shit
      $font_decrease.click (e) ->
        e.preventDefault()
        $active_lines.each ->
          $a = $ this
          c_s = $a.height()
          c_s = c_s-4
          $a.css
            'font-size': c_s+'px'
            'line-height': c_s+'px'
            'height': c_s
        position_these_buttons()
        save_pos_and_size()
      $font_increase.click (e) ->
        e.preventDefault()
        $active_lines.each ->
          $a = $ this
          c_s = $a.height()
          c_s = c_s+4
          $a.css
            'font-size': c_s+'px'
            'line-height': c_s+'px'
            'height': c_s
        position_these_buttons()
        save_pos_and_size()
      #
      #
      #
      #
      $active_lines = $lines.filter '.active'
      #
      #
      #
      # Set up Alignment Variables
      $alignments = $advanced_options.find '.alignment .option'
      $alignments.removeClass 'active'
      #
      #
      # Set up font variables
      $font_families = $advanced_options.find '.font_family'
      $font_families.removeClass 'active'
      #
      # Selec the currently active one on load
      $font_families.each ->
        $f = $ this
        if $f.html() is $active_lines.css('font-family').replace(/'/g,'')
          $f.addClass 'active'
          $advanced_options.find('.font_families').scrollTo $f
      #
      #
      #
      #
      #
  #
  #
  remove_buttons_from_active = ->
    $('.font_increase').remove()
    $('.font_decrease').remove()
  #
  #
  #
  #
  #
  update_background_of_active = ->
    $card.css
      background: '#FFFFFF url(\'//d3eo3eito2cquu.cloudfront.net/525x300/' + active_theme.s3_id + '\')'
    $active_thumb = $ '.category .card.active'
    $active_thumb.css
      background: '#FFFFFF url(\'//d3eo3eito2cquu.cloudfront.net/158x90/' + active_theme.s3_id + '\')'
    set_my_theme_save_timers()
  #
  #
  $('.upload input[type=file]').change ->
    $('.upload form').submit()
  #
  #
  # This catches the script parent.window call sent from app.coffee on the s3 form submit
  $.s3_result = (o) ->
    console.log o
    if o and o.s3_id
      active_theme.s3_id = o.s3_id
      update_background_of_active()
    else
      $.load_alert
        content: 'I had trouble saving that image, please try again later.'
  #
  show_advanced = ->
    $home_options.hide()
    $advanced_options.show()
    #
    #
    #
    #
    $patterns = $ '.patterns'
    $thumbs = $patterns.find '.thumb'
    #
    #
    #
    #
    #
    $thumbs.unbind().click ->
      $t = $ this
      active_theme.s3_id = $t.attr 's3_id'
      $thumbs.removeClass 'active'
      $t.addClass 'active'
      update_background_of_active()
    #
    #
    $tabs = $advanced_options.find '.tab_button li'
    $areas = $advanced_options.find '.area li'
    $tabs.unbind().click ->
      $t = $ this
      i = $t.prevAll().length
      $a = $areas.filter(':eq('+i+')')
      #
      #
      $areas.removeClass 'active'
      $a.addClass 'active'
      #
      $tabs.removeClass 'active'
      $t.addClass 'active'
      #
      #
      #
      remove_buttons_from_active()
      $lines.removeClass 'active'
      #
      # **********************************************************************
      # 
      #                          BACKGROUND TAB
      #
      # **********************************************************************
      if $t.html() is 'Background'
        $thumbs.removeClass 'active'
        $thumbs.each ->
          $t = $ this
          if $t.attr('s3_id') is active_theme.s3_id
            $t.addClass 'active'
            $patterns.find('.thumbs').scrollTo $t
      #
      #
      #
      # **********************************************************************
      #
      #                            TEXT TAB
      #
      # **********************************************************************
      if $t.html() is 'Text'
        #
        #
        #
        #
        #
        #
        #
        #
        #
        #
        # Area Selecting Binding Event Nonsense
        $card.unbind().bind 'mousedown', (e) ->
          #
          if e.target.className is 'font_decrease' or e.target.className is 'font_increase'
            return false
          #
          #
          #
          e_t = e.pageY - card_o.top
          e_l = e.pageX - card_o.left
          #
          e.preventDefault()
          $visible_lines = $lines.filter ':visible'
          $active_lines = $lines.filter '.active'
          #
          #
          #
          #
          #
          remove_buttons_from_active()
          #
          # ----------------------
          # Determine where we touched down at
          # ----------------------
          hit = false
          #
          $active_lines.each ->
            $l = $ this
            l_o = $l.offset()
            l_o_l = l_o.left - card_o.left
            l_o_t = l_o.top - card_o.top
            l_w = $l.width()
            l_h = $l.height()
            if e_l < l_o_l+l_w and e_l > l_o_l and e_t < l_o_t+l_h and e_t > l_o_t
              hit = true
          #
          #
          if hit
            # ----------------------
            # Move Stuff Around
            # ----------------------
            $active_lines.each ->
              $a = $ this
              $a.data 'o', $a.offset()
              $a.data 'h', $a.height()
              $a.data 'w', $a.width()

            $body.unbind('mousemove').bind 'mousemove', (e_2) ->
              e_2.preventDefault()
              x = e.pageX - e_2.pageX
              y = e.pageY - e_2.pageY
              $active_lines.each ->
                $a = $ this
                o = $a.data 'o'
                h = $a.data 'h'
                w = $a.data 'w'
                #
                # Figure out our dimensions
                new_t = o.top - card_o.top - y 
                new_l = o.left - card_o.left - x
                max_t = card_h - h - 10
                max_l = card_w - w - 10
                new_w = w
                #
                #
                # Make it skinnier if need be
                if new_l < -100
                  new_w = new_w+new_l+100
                if new_l > max_l+100
                  new_w = new_w+(max_l+100-new_l)
                  max_l = card_w - new_w - 10
                new_w = 50 if new_w < 50
                #
                # Boundary that shit
                new_t = 10 if new_t < 10
                new_l = 10 if new_l < 10
                new_t = max_t if new_t > max_t
                new_l = max_l if new_l > max_l
                #
                # Then set it
                $a.css
                  top: new_t
                  left: new_l
                  width: new_w
            $body.bind 'mouseup', (e_3) ->
              e_3.preventDefault()
              $body.unbind 'mousemove'
              $body.unbind 'mouseup'
              save_pos_and_size()
              add_buttons_to_active()

          else
            # ----------------------
            # Area drag selector
            # ----------------------
            $active_lines.removeClass 'active'
            $card.find('.highlight_box').remove()
            $highlight_box = $ '<div class="highlight_box" />'
            $card.append $highlight_box
            $body.unbind('mousemove').bind 'mousemove', (e_2) ->
              e_2.preventDefault()
              t = e_t
              l = e_l
              w = Math.abs(e.pageX - e_2.pageX)
              h = Math.abs(e.pageY - e_2.pageY)
              if e_2.pageX < e.pageX
                l = e_2.pageX - card_o.left
              if e_2.pageY < e.pageY
                t = e_2.pageY - card_o.top
              within = (x1,y1,x2,y2) -> x1 < (l+w) and x2 > l and y1 < t+h and y2 > t
              $highlight_box.css
                top: t
                left: l
                width: w
                height: h
              $visible_lines.each ->
                $l = $ this
                l_o = $l.offset()
                l_w = $l.width()
                l_h = $l.height()
                l_o_l = l_o.left - card_o.left
                l_o_t = l_o.top - card_o.top
                if within l_o_l, l_o_t, l_o_l+l_w, l_o_t+l_h
                  $l.addClass 'active' 
                else
                  $l.removeClass 'active'
            $body.bind 'mouseup', (e_3) ->
              e_3.preventDefault()
              $highlight_box.remove()
              $body.unbind 'mousemove'
              $body.unbind 'mouseup'
              add_buttons_to_active()

        #
        #
        #
        #
        $lines.filter(':eq(0)').addClass 'active'
        #
        add_buttons_to_active()
        #
        #
        #
        # Set up Alignment Variables
        $alignments = $advanced_options.find '.alignment'
        #
        # Font Changing Event
        $alignments.click ->
          $a = $ this
          #
          alignment = $a.attr 'alignment'
          #
          $alignments.removeClass 'active'
          $a.addClass 'active'
          #
          $active_lines = $lines.filter '.active'
          $active_lines.css 'text-align', alignment
          $active_lines.each ->
            $a = $ this
            index = $a.prevAll().length
            active_theme.theme_templates[active_view].lines[index].text_align = alignment
            set_my_theme_save_timers()
        #
        #
        # Set up font variables
        $font_families = $advanced_options.find '.font_family'
        #
        # Font Changing Event
        $font_families.click ->
          $f = $ this
          #
          new_font_family = $f.html()
          #
          $font_families.removeClass 'active'
          $f.addClass 'active'
          #
          $active_lines = $lines.filter '.active'
          $active_lines.css 'font-family', new_font_family
          $active_lines.each ->
            $a = $ this
            index = $a.prevAll().length
            active_theme.theme_templates[active_view].lines[index].font_family = new_font_family
            set_my_theme_save_timers()
      #
      #
      # **********************************************************************
      #
      #                              QR TAB
      #
      # **********************************************************************
      if $t.html() is 'QR'
        #
        #
        #
        console.log 'QR'

    $tabs.filter('.active').click()
    #
    #
  hide_advanced = ->
    $home_options.show()
    $advanced_options.hide()
  #
  #
  #
  my_theme_save_timer = 0
  set_my_theme_save_timers = ->
    if active_theme.category is 'My Own'
      clearTimeout my_theme_save_timer
      my_theme_save_timer = setTimeout ->
        $active_thumb = $ '.category .card.active'
        $active_thumb.data 'theme', active_theme
        update_preview_card_at_bottom()
        $.ajax
          url: '/save-theme'
          data: JSON.stringify
            theme: active_theme
            do_save: true
          success: (result) ->
            if not result.success
              console.log 'Error'
          error: ->
            console.log 'Error'
      , 1000
  #
  #
  #
  $home_options = $ '.home_options'
  $advanced_options = $ '.advanced_options'
  $design_my_own = $home_options.find '.advanced'
  $number_of_fields = $home_options.find '.views'
  $design_my_own.click ->
    #
    #
    active_theme = $.extend true, {}, active_theme
    #
    active_theme.category = 'My Own'
    active_theme._id = ''
    delete active_theme._id
    for theme_template, i in active_theme.theme_templates
      delete active_theme.theme_templates[i]._id
      for line, j in active_theme.theme_templates[i].lines
        delete active_theme.theme_templates[i].lines[j]._id
    #
    #
    $new_card = $.create_card_from_theme 
      theme: active_theme
      active_view: active_view
    $.add_card_to_category $new_card, active_theme
    $new_card.closest('.category').find('h4').click()
    #
    #
    set_my_theme_save_timers()
    #
    #

  #
  #
  #
  #
  #
  # END ADVANCED CARD DESIGNER
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
  $('.toggle .option').click ->
    $o = $ this
    $t = $o.closest '.toggle'
    #
    $t.find('.active').removeClass 'active'
    #
    $o.addClass 'active'
    #
    #
    index = $o.prevAll().length
    #
    #
    if $t.hasClass 'layout'
      active_view = index
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







