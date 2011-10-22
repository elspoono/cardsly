$ ->
  # function goes here
  $('.button').hover ->
    $(this).addClass 'hover'
  ,->
    $(this).removeClass 'hover'
  .mousedown ->
    $(this).addClass 'click'
  .mouseup ->
    $(this).removeClass 'click'

  # Define Margin
  newMargin = 0
  maxSlides = 2
  marginIncrement = 620
  maxSlides--

  advanceSlide = ->
    if newMargin < maxSlides * -marginIncrement
      newMargin=0
    else if newMargin > 0
      newMargin = maxSlides * -marginIncrement

    $('.slides .content').animate
      'margin-left': newMargin
    , 400

  $('.slides .arrow-right').click ->
    timer = 0
    newMargin -= marginIncrement
    advanceSlide()
  $('.slides .arrow-left').click ->
    timer = 0
    newMargin -= -marginIncrement
    advanceSlide()

  timer = setTimeout ->
    newMargin -= marginIncrement
    advanceSlide()
    timer = setInterval ->
      newMargin -= marginIncrement
      advanceSlide()
    , 5000
  , 2000