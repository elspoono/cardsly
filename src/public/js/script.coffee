$ ->
  # function goes here
  $('.add-button,.checkout-button').hover ->
    $(this).addClass 'hover'
  ,->
    $(this).removeClass 'hover'
  .mousedown ->
    $(this).addClass 'click'
  .mouseup ->
    $(this).removeClass 'click'