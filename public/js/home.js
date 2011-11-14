
  $(function() {
    var $biz_cards, $mc, $screens, $slides, $win, item_name, start_animation, update_cards;
    $biz_cards = $('.biz_cards');
    $slides = $('.slides');
    $screens = $slides.find('li');
    setInterval(function() {
      var $last_visible_guy;
      $last_visible_guy = $screens.filter(':visible:last');
      if ($last_visible_guy.length) {
        return $last_visible_guy.fadeOut();
      } else {
        return $screens.fadeIn();
      }
    }, 2000);
    start_animation = function() {
      return $biz_cards.animate({
        top: 0
      }, 3000, 'linear', function() {
        $biz_cards.css({
          top: -205
        });
        return start_animation();
      });
    };
    start_animation();
    /*
      Shopping Cart Stuff
    */
    item_name = '100 cards';
    $('.checkout').click(function() {
      $.load_alert({
        content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
      });
      return false;
    });
    $('.category h4').click(function() {
      var $a, $c, $g, $t;
      $t = $(this);
      $c = $t.closest('.category');
      $g = $c.find('.gallery');
      $a = $('.category.active');
      if (!$c.hasClass('active')) {
        $a.removeClass('active');
        $a.find('.gallery').show().slideUp(400);
        $gs.hide();
        $c.find('.gallery').slideDown(400, function() {
          $gs.show();
          return $c.find('.card:first').click();
        });
        return $c.addClass('active');
      }
    });
    $('.card.main input').each(function(i) {
      var $t;
      $t = $(this);
      $t.data('timer', 0);
      return $t.keyup(function() {
        update_cards(i, this.value);
        clearTimeout($t.data('timer'));
        $t.data('timer', setTimeout(function() {
          var array_oF_inpUt_values;
          $('.card.main input').each(function() {
            return $(this).trigger('clearMe');
          });
          /*
                    # TODO
                    #
                    # this.value should have a .replace ',' '\,'
                    # on it so that we can use a comma character and escape anything.
                    # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
          */
          array_oF_inpUt_values = $.makeArray($('.card.main input').map(function() {
            return this.value;
          }));
          console.log(array_oF_inpUt_values);
          $.ajax({
            url: '/save-form',
            data: {
              inputs: array_oF_inpUt_values.join('`~`')
            }
          });
          return false;
        }, 1000));
        return false;
      });
    });
    /*
      # Radio Button Clicking Stuff
    */
    $('.quantity input,.shipping_method input').bind('click change', function() {
      var $q, $s;
      $q = $('.quantity input:checked');
      $s = $('.shipping_method input:checked');
      return $('.order_total .price').html('$' + $q.val() * 1 + $s.val() * 1);
    });
    $win = $(window);
    $mc = $('.main.card');
    /*
      Update Cards
    
      This is used each time we need to update all the cards on the home page with the new content that's typed in.
    */
    update_cards = function(rowNumber, value) {
      return $('.card .content').each(function() {
        return $(this).find('li:eq(' + rowNumber + ')').html(value);
      });
    };
    return $win.scroll(function() {
      var newWinH, time_lapse;
      newWinH = $win.height() + $win.scrollTop();
      if ($mc.length) {
        if ($mc.offset().top + $mc.height() < newWinH && !$mc.data('didLoad')) {
          $mc.data('didLoad', true);
          time_lapse = 0;
          $('.main.card').find('input').each(function(rowNumber) {
            return update_cards(rowNumber, this.value);
          });
          return $('.main.card .defaults').find('input').each(function(rowNumber) {
            var $t, j, timers, v;
            $t = $(this);
            v = $t.val();
            $t.val('');
            timers = (function() {
              var _ref, _results;
              _results = [];
              for (j = 0, _ref = v.length; 0 <= _ref ? j <= _ref : j >= _ref; 0 <= _ref ? j++ : j--) {
                _results.push((function(j) {
                  var timer;
                  timer = setTimeout(function() {
                    var v_substring;
                    v_substring = v.substr(0, j);
                    $t.val(v_substring);
                    return update_cards(rowNumber, v_substring);
                  }, time_lapse * 70);
                  time_lapse++;
                  return timer;
                })(j));
              }
              return _results;
            })();
            $t.bind('clearMe', function() {
              var i, _i, _len;
              console.log($t.data('cleared'));
              if (!$t.data('cleared')) {
                for (_i = 0, _len = timers.length; _i < _len; _i++) {
                  i = timers[_i];
                  clearTimeout(i);
                }
                $t.val('');
                update_cards(rowNumber, '');
                return $t.data('cleared', true);
              }
            });
            return $t.bind('focus', function() {
              return $t.trigger('clearMe');
            });
          });
        }
      }
    });
    /*
      #
      # The floaty guy behind the gallery selection
      $gs = $ '.gallery_select'
      $gs.css
        left: -220
        top: 0
      $('.gallery .card').live 'click', () ->
        $t = $ this
        $('.card').removeClass 'active'
        $t.addClass('active')
        $find_class = $t.clone()
        class_name = $find_class.removeClass('card')[0].class_name
        $find_class.remove()
        $('.main').attr
          class: 'card main '+class_name
        if $gs.offset().top == $t.offset().top_10
          $gs.animate
            left: $t.offset().left_10
          ,500
        else
          $gs.stop(true,false).animate
            top: $t.offset().top_10
          ,500,'linear',() ->
              $gs.animate
                left: $t.offset().left_10
              ,500,'linear'
      $gs.bind 'activeMoved', ->
        $a = $ '.card.active'
        $gs.css
          left: $a.offset().left_10
          top: $a.offset().top_10
      $(window).load () ->
        $('.gallery:first .card:first').click()
    */
  });
