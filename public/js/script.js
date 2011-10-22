(function() {
  $(function() {
    var $win, advanceSlide, hasHidden, i, marginIncrement, maxSlides, newMargin, timer, winH, _i, _len;
    $win = $(window);
    winH = $win.height() + $win.scrollTop();
    hasHidden = [];
    $('.section-to-hide').each(function() {
      var $this, thisT;
      $this = $(this);
      thisT = $this.offset().top;
      if (winH < thisT) {
        return hasHidden.push({
          $this: $this,
          thisT: thisT
        });
      }
    });
    for (_i = 0, _len = hasHidden.length; _i < _len; _i++) {
      i = hasHidden[_i];
      i.$this.hide();
    }
    $win.scroll(function() {
      var i, newWinH, _j, _len2, _results;
      newWinH = $win.height() + $win.scrollTop();
      _results = [];
      for (_j = 0, _len2 = hasHidden.length; _j < _len2; _j++) {
        i = hasHidden[_j];
        _results.push(i.thisT - 50 < newWinH ? i.$this.fadeIn(2000) : void 0);
      }
      return _results;
    });
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
    maxSlides = 3;
    marginIncrement = 620;
    maxSlides--;
    advanceSlide = function() {
      if (newMargin < maxSlides * -marginIncrement) {
        newMargin = 0;
      } else if (newMargin > 0) {
        newMargin = maxSlides * -marginIncrement;
      }
      return $('.slides .content').stop(true, false).animate({
        'margin-left': newMargin
      }, 400);
    };
    $('.slides .arrow-right').click(function() {
      marginIncrement = $('.slides').width();
      clearTimeout(timer);
      newMargin -= marginIncrement;
      return advanceSlide();
    });
    $('.slides .arrow-left').click(function() {
      marginIncrement = $('.slides').width();
      clearTimeout(timer);
      newMargin -= -marginIncrement;
      return advanceSlide();
    });
    return timer = setTimeout(function() {
      marginIncrement = $('.slides').width();
      newMargin -= marginIncrement;
      advanceSlide();
      clearTimeout(timer);
      return timer = setInterval(function() {
        marginIncrement = $('.slides').width();
        newMargin -= marginIncrement;
        return advanceSlide();
      }, 6500);
    }, 3000);
  });
}).call(this);
