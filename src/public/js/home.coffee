

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

  console.log $screens

  #
  # Let's change the screens periodically
  setInterval ->

    $last_visible_guy = $screens.filter(':visible:last')

    if $last_visible_guy.length
      $last_visible_guy.fadeOut()
    else
      $screens.fadeIn()

  , 2000

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

