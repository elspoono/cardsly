$ ->

  

  $win = $(window)
  winH = $win.height()+$win.scrollTop()
  hasHidden = []
  $('.section-to-hide').each ->
    $this = $(this)
    thisT = $this.offset().top
    if(winH<thisT)
      hasHidden.push
        $this: $this
        thisT: thisT
  for i in hasHidden
    i.$this.hide()
  $win.scroll ->
    newWinH = $win.height()+$win.scrollTop()
    for i in hasHidden
      if i.thisT-50 < newWinH
        i.$this.fadeIn(2000)


  # Buttons everywhere need hover and click states
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
  maxSlides = 3
  marginIncrement = 620
  maxSlides--


  # Home Page Stuff

  # each advance of the slide
  advanceSlide = ->
    marginIncrement = $('.slides').width()
    if newMargin < maxSlides * -marginIncrement
      newMargin=0
    else if newMargin > 0
      newMargin = maxSlides * -marginIncrement

    $('.slides .content').stop(true,false).animate
      'margin-left': newMargin
    , 400

  # click events
  $('.slides .arrow-right').click ->
    clearTimeout(timer)
    newMargin -= marginIncrement
    advanceSlide()
  $('.slides .arrow-left').click ->
    clearTimeout(timer)
    newMargin -= -marginIncrement
    advanceSlide()

  # The timer that starts and then repeats (cancelled on click)
  timer = setTimeout ->
    newMargin -= marginIncrement
    advanceSlide()
    clearTimeout(timer)
    timer = setInterval ->
      newMargin -= marginIncrement
      advanceSlide()
    , 6500
  , 3000