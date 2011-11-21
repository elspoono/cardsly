##################################################################

###

This is only for the home page

- Home page animations
- Gallery selection on the home page

###

##################################################################








# THIS is the jQuery document.ready
$ ->
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
  $body = $ document
  #









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
    wait_delay = quick_time*3
    if wait_delay <= 150
      wait_delay = 0
    $label_away.stop(true,true).show().css
      'margin-left': 0
    $label_away.delay(wait_delay).animate
      'margin-left': -233
    ,quick_time
    $guy_im_fading_out.stop(true,true).show().css
      'margin-left': 0
    $guy_im_fading_out.delay(wait_delay).animate
      'margin-left': -233
    ,quick_time
    $phone_scanner.stop(true,false)
    #
    #
    #
    # STEP 2: Flash The Light
    #
    $phone_scanner.fadeIn(quick_time).delay(quick_time).fadeOut(quick_time)
    #
    # STEP 3: Bring things in
    #
    wait_delay = quick_time*4
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
    if $.browser.msie and parseInt($.browser.version, 10)<8
      console.log 'Do something for IE7 here'
    else
      my_repeatable_function()
  #
  #
  #
  #
  #
  # END HOME PAGE ANIMATIONS
  #
  #
  ##################################################################