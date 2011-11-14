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
  $screens = $slides.find 'li'

  screens_fade_out = ->
    $screens.fadeOut 5000, ->
      screens_fade_in()
  
  screens_fade_in = ->
    num_slides = 1 ++
    
    $screens.fadeOut 5000, ->
      screens_fade_out()


 
  #
  ### Let's change the screens periodically
  setInterval ->

    $last_visible_guy = $screens.filter(':visible:last')

    if $last_visible_guy.length
      $last_visible_guy.fadeOut()
    else
      $screens.fadeIn()

  , 2000
  ###

  #
  # Slide the business card down slowly
  #
  # Create a repeatable function
  start_animation = ->
    $biz_cards.animate
      top: 0
    , 3000, 'linear', ->
      # reset the style to it's default
      $biz_cards.css
        top: -205
      # repeat the function
      start_animation()
  # Fire the function in the first place on page load (cause we're inside this jquery document.ready)
  start_animation()
  screens_fade_out()
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
