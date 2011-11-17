##################################################################

###

This is only for the home page

- Home page animations
- Gallery selection on the home page

###

##################################################################








# THIS is the jQuery document.ready
$ ->
  # So everything indented here happens on page load

  # What is the first thing we want to do
  #
  # Grab all our jQuery guys that we're going to re use
  # (this is effectively instantiating classes)
  $biz_cards = $ '.biz_cards'
  $slides = $ '.slides'
  $phone_scanner = $ '.phone_scanner'
  $lis = $slides.find 'li'
  $loading_screen = $ '.loading_screen'
  #
  # Hide all the stuff to hide
  $lis.hide()
  $phone_scanner.hide()
  $designer = $ '.home_designer'
  $categories = $ '.categories'
  $card = $designer.find '.card'
  $qr = $card.find '.qr'
  $qr_bg = $qr.find '.background'
  $lines = $card.find '.line'
  #

  $view_buttons = $ '.views .option'
  #
  $body = $ document
  #
  #
  # Set some constants
  active_theme = false
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
  $qr.prep_qr()



  ##############
  #
  # GOOGLE FONTS
  #
  # 1. Load them
  # 2. Make their common names available
  #
  #
  # Loading Them
  setTimeout ->
    WebFont.load google:
      families: [ "IM+Fell+English+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin" ]
  ,3000
  #
  #
  # END GOOGLE FONTS
  #
  ################

  
  ##############
  #
  # The Themes
  #
  $.ajax
    url: '/get-themes'
    success: (all_data) ->
      all_themes = all_data.themes
      $categories.html ''
      for theme in all_themes
        #
        #
        #
        $my_card = $.create_card_from_theme theme
        
        # Push the whole thing to categories
        $.add_card_to_category $my_card, theme
      #
      #
      # Click the first theme
      $categories.find('.category:first h4').click()
      #
      # Restore active view
      $active_view = $ '.active_view'
      if $active_view.html()
        $view_buttons.filter(':eq(' + $active_view.html() + ')').click()

    error: ->
      $.load_alert
        content: 'Error loading themes. Please try again later.'
  $('.category .card').live 'click', () ->
    $t = $ this
    theme = $t.data 'theme'
    if active_theme._id
      $a = $ '.category .card'
      $a.each ->
        $t = $ this
        if $t.data('theme') and $t.data('theme')._id == active_theme._id
          $t.data 'theme', active_theme
    if theme
      load_theme theme
      history = [theme]
  #
  #
  #
  # END The Themes
  #
  #
  ##############

  load_theme = (theme) ->
    #
    # Set Constants
    theme_template = theme.theme_templates[active_view]
    #
    if !theme_template
      if active_view is 2
        theme_template = $.extend true, {}, theme.theme_templates[0]
      if active_view is 1
        theme_template = $.extend true, {}, theme.theme_templates[0]
        for line in theme_template.lines
          $.extend true, line,
            h: line.h/1.5
            w: line.w/1.5
          new_line = $.extend true, {}, line
          new_line.x = 100-new_line.x-new_line.w
          theme_template.lines.push new_line
        theme_template.qr.h = theme_template.qr.h/1.5
        theme_template.qr.w = theme_template.qr.w/1.5
      theme.theme_templates[active_view] = theme_template
    if active_view is 1 and theme.theme_templates[active_view].lines.length > 10
      theme.theme_templates[active_view].lines.splice 10, 5
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
        background: '#FFFFFF url(\'http://cdn.cards.ly/525x300/' + theme_template.s3_id + '\')'
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
    # Show the qr code and set it to the right place
    $qr.show().css
      top: theme_template.qr.y/100 * card_height
      left: theme_template.qr.x/100 * card_width
      height: theme_template.qr.h/100 * card_height
      width: theme_template.qr.h/100 * card_height
    $qr.find('canvas').css
      height: theme_template.qr.h/100 * card_height
      width: theme_template.qr.h/100 * card_height
    $qr_bg.css
      'border-radius': theme_template.qr.radius+'px'
      height: theme_template.qr.h/100 * card_height
      width: theme_template.qr.w/100 * card_width
      background: '#'+theme_template.qr.color2
    $qr_bg.fadeTo 0, theme_template.qr.color2_alpha
    $qr.draw_qr
      color: theme_template.qr.color1
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
  # DRAW SOME QR CODES
  $biz_cards.find('li').each (i) ->
    $t = $ this
    $my_qr = $t.find '.qr'

    $my_qr.qr
      url: 'http://cards.ly/' + Math.random()
      height: 70
      width: 70
  #
  #
  # Find our total length
  iterate_num = $lis.length
  current_num = 0
  #
  #
  my_repeatable_function = ->
    #
    #
    $guy_im_fading_out = $lis.filter ':eq(' + current_num + ')'
    $my_next_guy = $lis.filter ':eq(' + (current_num+1) + ')'
    #
    #
    if not $my_next_guy.length
      $my_next_guy = $lis.filter(':first')
    #
    #
    $guy_im_fading_out.stop(true,true).delay(200).fadeOut 50
    $loading_screen.stop(true,true).fadeIn(400).delay(100).fadeOut(400)

    $my_next_guy.stop(true,true).delay(600).fadeIn 500
    #
    $phone_scanner.stop(true,true).fadeIn(300).fadeOut(300)
    #
    #
    $biz_cards.stop(true,true)
    #
    $biz_cards.delay(500).animate
      top: 5
    , 3500, 'linear', ->
      # reset the style to it's default
      $biz_cards.css
        top: -205
    #
    #
    current_num++
    current_num = 0 if current_num == iterate_num
  #
  #
  # Create an interval function
  setInterval my_repeatable_function, 4000
  #
  #
  #
  my_repeatable_function()
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

  input_timer = 0
  set_timers = ->
    clearTimeout input_timer
    input_timer = setTimeout ->
        ###
        # TODO
        #
        # this.value should have a .replace ',' '\,'
        # on it so that we can use a comma character and escape anything.
        # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
        ###
        values = $.makeArray $lines.map -> 
          $(this).html()
        $.ajax
          url: '/save-form'
          data: JSON.stringify 
            values: values
            active_view: active_view
        false
      ,1000
  #
  # Form Fields
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
        if e.keyCode is 13 or e.keyCode is 9
          e.preventDefault()
          $next = $t.nextAll('div:first:visible')
          if i is 5
            $next = $t.nextAll('div:first')
          if not $next.length
            $next = $lines.filter(':first')
          $next.click()
          return false
      $input.keyup (e) ->
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
  
  ###
  # Radio Button Clicking Stuff
  ###
  #
  # Radio Select
  $('.quantity input,.shipping_method input').bind 'click change', () ->
    $q = $('.quantity input:checked')
    $s = $('.shipping_method input:checked')
    console.log $q, $s
    $('.order_total .price').html '$' + (($q.val()*1) + ($s.val()*1))

  # Window and Main Card to use later
  $win = $ window
  $mc = $ '.home_designer'
  


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
    load_theme active_theme
    set_timers()

  ###
  Update Cards

  This is used each time we need to update all the cards on the home page with the new content that's typed in.
  ###
  update_cards = (rowNumber, value) ->
    $('.categories .card').each -> 
      $t = $ this
      $t.find('.line:eq('+rowNumber+')').html value


  # On the window scroll event ...
  $win.scroll ->

    # Get the new bottom of the window position
    newWinH = $win.height()+$win.scrollTop()
    if $mc.length
      # If the main card bottom is now visible
      if $mc.offset().top+$mc.height() < newWinH && !$mc.data 'didLoad'
        $mc.data 'didLoad', true
        time_lapse = 0
        $lines.each (rowNumber) ->
          $t = $ this
          v = $t.val() || $t.html()
          $t.val ''
          update_cards rowNumber, v
          timers = for j in [0..v.length]
            do (j) ->
              timer = setTimeout ->
                v_substring = v.substr 0,j
                $t.html v_substring
                update_cards rowNumber, v_substring
              ,time_lapse*70
              time_lapse++
              timer
