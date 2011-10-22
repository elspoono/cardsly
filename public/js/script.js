(function() {
  $(function() {
    var advanceSlide, marginIncrement, maxSlides, newMargin, timer;
    $('.button').hover(function() {
      return $(this).addClass('hover');
    }, function() {
      return $(this).removeClass('hover');
    }).mousedown(function() {
      return $(this).addClass('click');
    }).mouseup(function() {
      return $(this).removeClass('click');
    });
    newMargin = 0;
    maxSlides = 2;
    marginIncrement = 620;
    maxSlides--;
    advanceSlide = function() {
      if (newMargin < maxSlides * -marginIncrement) {
        newMargin = 0;
      } else if (newMargin > 0) {
        newMargin = maxSlides * -marginIncrement;
      }
      return $('.slides .content').animate({
        'margin-left': newMargin
      }, 400);
    };
    $('.slides .arrow-right').click(function() {
      clearTimeout(timer);
      newMargin -= marginIncrement;
      return advanceSlide();
    });
    $('.slides .arrow-left').click(function() {
      clearTimeout(timer);
      newMargin -= -marginIncrement;
      return advanceSlide();
    });
    return timer = setTimeout(function() {
      newMargin -= marginIncrement;
      advanceSlide();
      clearTimeout(timer);
      return timer = setInterval(function() {
        newMargin -= marginIncrement;
        return advanceSlide();
      }, 6500);
    }, 3000);
  });
}).call(this);
