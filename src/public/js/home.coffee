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
  $imgs = $slides.find 'img'
  $labels = $slides.find 'label'
  $loading_screen = $ '.loading_screen'
  #
  # Hide all the stuff to hide
  $imgs.hide()
  $phone_scanner.hide()
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
  $city = $('.city')
  #
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
  # The Themes
  #
  $.ajax
    url: '/get-themes'
    success: (all_data) ->
      all_themes = all_data.themes
      $categories.html ''
      active_theme_id = $('.active_theme_id').html()
      $active_theme = false
      for theme in all_themes
        #
        #
        #
        $my_card = $.create_card_from_theme theme
        
        if active_theme_id and theme._id is active_theme_id
          $active_theme = $my_card

        # Push the whole thing to categories
        $.add_card_to_category $my_card, theme
      #
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
      # Restore active view
      $active_view = $ '.active_view'
      if $active_view.html()
        $view_buttons.filter(':eq(' + $active_view.html() + ')').click()
      #
      #
      #
      $lines.each (i) ->
        update_cards i, $(this).html()

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
  #
  #
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
            active_theme_id: active_theme._id
        false
      ,1000
  #
  ###
  Update Cards

  This is used each time we need to update all the cards on the home page with the new content that's typed in.
  ###
  update_cards = (rowNumber, value) ->
    $('.categories .card').each -> 
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








  ###
  # Radio Button Clicking Stuff
  ###
  #
  # Radio Select
  $('.quantity input,.shipping_method input').bind 'change', () ->
    $q = $('.quantity input:checked')
    $s = $('.shipping_method input:checked')
    $('.order_total .price').html '$' + (($q.val()*1) + ($s.val()*1))
    #
    #
    #
    set_timers()
  #
  #
  #
  $address.keyup ->
    $t = $ this
    v = $t.val()
    if v is ''
      $t.show_tooltip
        message: 'Please enter a street address'
  #
  #
  $city.keyup ->
    $t = $ this
    v = $t.val()
    if v is ''
      $t.show_tooltip
        message: 'Please enter zip code'
  #
  #
  #
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









  ##################################################################
  #
  # HOME PAGE ANIMATIONS
  #
  #
  # - the biz card sliding up and down and
  # - the phone flashing and changing
  #
  #
  #
  #
  # DRAW SOME QR CODES
  for i in [0..$imgs.length]
    $li = $ '<li />'
    $my_qr = $ '<div class="qr" />'
    $img = $ '<img src="/images/biz_card1.png">'
    $my_qr.qr
      url: 'http://cards.ly/'+Math.random()
      height: 44
      width: 44
    $my_qr.css
      position: 'absolute'
      top: 56
      left: 185
    $img.css
      height: 142
    $li.append $my_qr
    $li.append $img
    $biz_cards.append $li
  #
  #
  biz_incr = 142+30
  biz_begin = (-$imgs.length-.75)*biz_incr
  $biz_cards.css
    top: biz_begin
  $biz_cards.find('li').hide().fadeIn()
  #
  # Find our total length
  iterate_num = $imgs.length
  current_num = 0
  #
  #
  $loading_screen.hide()
  frame_time = 4000
  quick_time = 200
  #
  my_repeatable_function = ->
    #
    #
    $guy_im_fading_out = $imgs.filter ':eq(' + current_num + ')'
    $my_next_guy = $imgs.filter ':eq(' + (current_num+1) + ')'
    #
    $label_away = $labels.filter ':eq(' + (current_num) + ')'
    $label_to = $labels.filter ':eq(' + (current_num+1) + ')'
    #
    #
    if not $my_next_guy.length
      $my_next_guy = $imgs.filter(':first')
      $label_to = $labels.filter(':first')
    #
    #
    #
    # STEP 1: Stop
    #
    # - stop the biz cards, slide stuff out
    #
    $label_away.stop(true,true).show().css
      'margin-left': 0
    $label_away.animate
      'margin-left': -233
    ,quick_time
    $guy_im_fading_out.stop(true,true).show().css
      'margin-left': 0
    $guy_im_fading_out.animate
      'margin-left': -233
    ,quick_time
    $phone_scanner.stop(true,true)
    #
    #
    #
    # STEP 2: Flash The Light
    #
    $phone_scanner.delay(quick_time).fadeIn(quick_time).delay(quick_time).fadeOut(quick_time)
    #
    # STEP 3: Bring things in
    #
    wait_delay = quick_time*3
    if wait_delay <= 200
      wait_delay = 0
    $my_next_guy.show().css
      'margin-left': 233
    $my_next_guy.delay(wait_delay).animate
      'margin-left': 0
    ,quick_time
    $label_to.show().css
      'margin-left': 233
    $label_to.delay(wait_delay).animate
      'margin-left': 0
    ,quick_time
    #
    #
    #
    # STEP 4: Start the biz cards again
    #
    # reset the[ style to it's default
    biz_delay = quick_time*4
    style = 'swing'
    if biz_delay <= 200
      biz_delay = 0
      style = 'linear'
    $biz_cards.stop(true,true)
    $biz_cards.delay(biz_delay).animate
      top: parseInt($biz_cards.css('top')) + biz_incr
    , frame_time-biz_delay, style
    #
    #
    current_num++
    current_num = 0 if current_num == iterate_num
    #
    #
    #
    #
    # Create an interval function
    timer = setTimeout my_repeatable_function, frame_time
    #
    frame_time = frame_time - 950
    quick_time = quick_time - 30
    if frame_time <= 500 
      frame_time = frame_time + 850
      quick_time = 50
    if frame_time <= 200 
      frame_time = 200
      quick_time = 50
      index = $my_next_guy.parent().prevAll().length
      if index is 0
        clearTimeout timer
        frame_time = 4000
        quick_time = 200
        $label_to.stop(true,true).css
          'margin-left': 0
        $label_to.delay(2000).fadeOut(3000)
        $biz_cards.stop(true,true).animate
          top: parseInt($biz_cards.css('top')) + biz_incr*6
        , 1200
        $my_next_guy.fadeOut(500)
        $('.slide:last').stop(true,true).delay(500).fadeIn(2000).delay(5500).fadeOut(2000)
        #
        timer = setTimeout ->
          $biz_cards.find('li').hide().fadeIn()
          $biz_cards.stop(true,true).css
            top: biz_begin
          my_repeatable_function()
        , 12000
      
        #
    #
  #
  #
  #
  $(window).load ->
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
  #
  #
  #
  #
  #
  # END HOME PAGE ANIMATIONS
  #
  #
  ##################################################################