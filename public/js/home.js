(function() {
  /*
  
  This is only for the home page
  
  - Home page animations
  - Gallery selection on the home page
  
  */  $(function() {
    var $biz_cards, $lis, $loading_screen, $mc, $phone_scanner, $slides, $win, current_num, item_name, iterate_num, my_repeatable_function, update_cards;
    $biz_cards = $('.biz_cards');
    $slides = $('.slides');
    $phone_scanner = $('.phone_scanner');
    $lis = $slides.find('li');
    console.log($lis);
    $loading_screen = $('.loading_screen');
    $lis.hide();
    $phone_scanner.hide();
    $biz_cards.find('li').each(function(i) {
      var $qr, $t;
      $t = $(this);
      $qr = $t.find('.qr');
      return $qr.qr({
        url: 'http://cards.ly/' + Math.random(),
        height: 70,
        width: 70
      });
    });
    iterate_num = $lis.length;
    current_num = 0;
    my_repeatable_function = function() {
      var $guy_im_fading_out, $my_next_guy;
      $guy_im_fading_out = $lis.filter(':eq(' + current_num + ')');
      $my_next_guy = $lis.filter(':eq(' + (current_num + 1) + ')');
      if (!$my_next_guy.length) {
        $my_next_guy = $lis.filter(':first');
      }
      $guy_im_fading_out.stop(true, true).delay(200).fadeOut(50);
      $loading_screen.stop(true, true).fadeIn(400).delay(100).fadeOut(400);
      $my_next_guy.stop(true, true).delay(600).fadeIn(500);
      $phone_scanner.stop(true, true).fadeIn(300).fadeOut(300);
      $biz_cards.stop(true, true);
      $biz_cards.delay(500).animate({
        top: 5
      }, 3500, 'linear', function() {
        return $biz_cards.css({
          top: -205
        });
      });
      current_num++;
      if (current_num === iterate_num) {
        return current_num = 0;
      }
    };
    setInterval(my_repeatable_function, 4000);
    my_repeatable_function();
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
  });
}).call(this);
