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
    clearTimeout(timer)
    newMargin -= marginIncrement
    advanceSlide()
  $('.slides .arrow-left').click ->
    clearTimeout(timer)
    newMargin -= -marginIncrement
    advanceSlide()

  timer = setTimeout ->
    newMargin -= marginIncrement
    advanceSlide()
    clearTimeout(timer)
    timer = setInterval ->
      newMargin -= marginIncrement
      advanceSlide()
    , 6500
  , 3000