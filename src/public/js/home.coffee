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
  console.log $lis
  #
  # Hide all the stuff to hide
  $lis.hide()
  $phone_scanner.hide()
  #
  #
  # DRAW SOME QR CODES
  $biz_cards.find('li').each (i) ->
    $t = $ this
    $qr = $t.find '.qr'

    $qr.qr
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
    $guy_im_fading_out.stop(true,true).delay(600).fadeOut 500
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
            url: '/save-form'
            data:
              inputs: array_oF_inpUt_values.join('`~`')
          false
        ,1000
      false
  
  ###
  # Radio Button Clicking Stuff
  ###
  #
  # Radio Select
  $('.quantity input,.shipping_method input').bind 'click change', () ->
    $q = $('.quantity input:checked')
    $s = $('.shipping_method input:checked')
    $('.order_total .price').html '$' + $q.val()*1 + $s.val()*1

  # Window and Main Card to use later
  $win = $ window
  $mc = $ '.main.card'
  

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
