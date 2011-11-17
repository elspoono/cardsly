(function() {
  /*
  
  This is only for the home page
  
  - Home page animations
  - Gallery selection on the home page
  
  */  $(function() {
    var $biz_cards, $body, $card, $categories, $designer, $img, $imgs, $labels, $li, $lines, $loading_screen, $mc, $my_qr, $phone_scanner, $qr, $qr_bg, $slides, $view_buttons, $win, active_theme, active_view, biz_begin, biz_incr, card_height, card_inner_height, card_inner_width, card_width, current_num, frame_time, i, input_timer, item_name, iterate_num, load_theme, my_repeatable_function, quick_time, set_timers, shift_pressed, update_card_size, update_cards, _ref;
    $biz_cards = $('.biz_cards');
    $slides = $('.slides');
    $phone_scanner = $('.phone_scanner');
    $imgs = $slides.find('img');
    $labels = $slides.find('label');
    $loading_screen = $('.loading_screen');
    $imgs.hide();
    $phone_scanner.hide();
    $designer = $('.home_designer');
    $categories = $('.categories');
    $card = $designer.find('.card');
    $qr = $card.find('.qr');
    $qr_bg = $qr.find('.background');
    $lines = $card.find('.line');
    $view_buttons = $('.views .option');
    $body = $(document);
    active_theme = false;
    active_view = 0;
    card_height = 0;
    card_width = 0;
    card_inner_height = 0;
    card_inner_width = 0;
    update_card_size = function() {
      card_height = $card.outerHeight();
      card_width = $card.outerWidth();
      card_inner_height = $card.height();
      return card_inner_width = $card.width();
    };
    update_card_size();
    $qr.prep_qr();
    setTimeout(function() {
      return WebFont.load({
        google: {
          families: ["IM+Fell+Engimgsh+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin"]
        }
      });
    }, 5000);
    $.ajax({
      url: '/get-themes',
      success: function(all_data) {
        var $active_view, $my_card, all_themes, theme, _i, _len;
        all_themes = all_data.themes;
        $categories.html('');
        for (_i = 0, _len = all_themes.length; _i < _len; _i++) {
          theme = all_themes[_i];
          $my_card = $.create_card_from_theme(theme);
          $.add_card_to_category($my_card, theme);
        }
        $categories.find('.category:first h4').click();
        $active_view = $('.active_view');
        if ($active_view.html()) {
          return $view_buttons.filter(':eq(' + $active_view.html() + ')').click();
        }
      },
      error: function() {
        return $.load_alert({
          content: 'Error loading themes. Please try again later.'
        });
      }
    });
    $('.category .card').live('click', function() {
      var $a, $t, history, theme;
      $t = $(this);
      theme = $t.data('theme');
      if (active_theme._id) {
        $a = $('.category .card');
        $a.each(function() {
          $t = $(this);
          if ($t.data('theme') && $t.data('theme')._id === active_theme._id) {
            return $t.data('theme', active_theme);
          }
        });
      }
      if (theme) {
        load_theme(theme);
        return history = [theme];
      }
    });
    load_theme = function(theme) {
      var $li, i, line, new_line, pos, theme_template, _i, _len, _len2, _ref, _ref2, _results;
      theme_template = theme.theme_templates[active_view];
      if (!theme_template) {
        if (active_view === 2) {
          theme_template = $.extend(true, {}, theme.theme_templates[0]);
        }
        if (active_view === 1) {
          theme_template = $.extend(true, {}, theme.theme_templates[0]);
          _ref = theme_template.lines;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            $.extend(true, line, {
              h: line.h / 1.5,
              w: line.w / 1.5
            });
            new_line = $.extend(true, {}, line);
            new_line.x = 100 - new_line.x - new_line.w;
            theme_template.lines.push(new_line);
          }
          theme_template.qr.h = theme_template.qr.h / 1.5;
          theme_template.qr.w = theme_template.qr.w / 1.5;
        }
        theme.theme_templates[active_view] = theme_template;
      }
      if (active_view === 1 && theme.theme_templates[active_view].lines.length > 10) {
        theme.theme_templates[active_view].lines.splice(10, 5);
      }
      active_theme = theme;
      if (theme_template.s3_id) {
        $card.css({
          background: '#FFFFFF url(\'http://cdn.cards.ly/525x300/' + theme_template.s3_id + '\')'
        });
      } else {
        $card.css({
          background: '#FFFFFF'
        });
        $card.css({
          height: 280,
          width: 505,
          padding: 10,
          margin: 0
        });
        update_card_size();
      }
      $qr.hide();
      $lines.hide();
      $qr.show().css({
        top: theme_template.qr.y / 100 * card_height,
        left: theme_template.qr.x / 100 * card_width,
        height: theme_template.qr.h / 100 * card_height,
        width: theme_template.qr.h / 100 * card_height
      });
      $qr.find('canvas').css({
        height: theme_template.qr.h / 100 * card_height,
        width: theme_template.qr.h / 100 * card_height
      });
      $qr_bg.css({
        'border-radius': theme_template.qr.radius + 'px',
        height: theme_template.qr.h / 100 * card_height,
        width: theme_template.qr.w / 100 * card_width,
        background: '#' + theme_template.qr.color2
      });
      $qr_bg.fadeTo(0, theme_template.qr.color2_alpha);
      $qr.draw_qr({
        color: theme_template.qr.color1
      });
      _ref2 = theme_template.lines;
      _results = [];
      for (i = 0, _len2 = _ref2.length; i < _len2; i++) {
        pos = _ref2[i];
        $li = $lines.eq(i);
        _results.push($li.show().css({
          top: pos.y / 100 * card_height,
          left: pos.x / 100 * card_width,
          width: (pos.w / 100 * card_width) + 'px',
          height: (pos.h / 100 * card_height) + 'px',
          fontSize: (pos.h / 100 * card_height) + 'px',
          lineHeight: (pos.h / 100 * card_height) + 'px',
          fontFamily: pos.font_family,
          textAlign: pos.text_align,
          color: '#' + pos.color
        }));
      }
      return _results;
    };
    input_timer = 0;
    set_timers = function() {
      clearTimeout(input_timer);
      return input_timer = setTimeout(function() {
        /*
                # TODO
                #
                # this.value should have a .replace ',' '\,'
                # on it so that we can use a comma character and escape anything.
                # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
                */
        var values;
        values = $.makeArray($lines.map(function() {
          return $(this).html();
        }));
        $.ajax({
          url: '/save-form',
          data: JSON.stringify({
            values: values,
            active_view: active_view
          })
        });
        return false;
      }, 1000);
    };
    shift_pressed = false;
    $lines.each(function(i) {
      var $t;
      $t = $(this);
      $t.data('timer', 0);
      return $t.click(function() {
        var $input, remove_input, style;
        if (i === 6) {
          $view_buttons.filter(':last').click();
        }
        style = $t.attr('style');
        $input = $('<input class="line" />');
        $input.attr('style', style);
        $input.val($t.html());
        $t.after($input);
        $t.hide();
        $input.focus().select();
        $input.keydown(function(e) {
          var $next;
          if (e.keyCode === 16) {
            shift_pressed = true;
          }
          if (e.keyCode === 13 || e.keyCode === 9) {
            e.preventDefault();
            $next = $t.nextAll('div:visible:first');
            if (shift_pressed) {
              $next = $t.prev();
              if (!$next.length) {
                $next = $lines.filter(':visible:last');
              }
            } else {
              /*
                          Uncomment this to allow entering to 10 mode
                          if i is 5
                            $next = $t.nextAll('div:first')
                          */
              if (!$next.length) {
                $next = $lines.filter(':first');
              }
            }
            $next.click();
            return false;
          }
        });
        $input.keyup(function(e) {
          if (e.keyCode === 16) {
            shift_pressed = false;
          }
          update_cards(i, this.value);
          $t.html(this.value);
          return set_timers();
        });
        remove_input = function(e) {
          var $target;
          $target = $(e.target);
          if ($target[0] !== $t[0] && $target[0] !== $input[0]) {
            $body.unbind('click', remove_input);
            $input.remove();
            return $t.show();
          }
        };
        return $body.bind('click', remove_input);
      });
    });
    /*
      # Radio Button Clicking Stuff
      */
    $('.quantity input,.shipping_method input').bind('click change', function() {
      var $q, $s;
      $q = $('.quantity input:checked');
      $s = $('.shipping_method input:checked');
      console.log($q, $s);
      return $('.order_total .price').html('$' + (($q.val() * 1) + ($s.val() * 1)));
    });
    $win = $(window);
    $mc = $('.home_designer');
    $view_buttons.click(function() {
      var $t, index;
      $t = $(this);
      $view_buttons.filter('.active').removeClass('active');
      $t.addClass('active');
      index = $t.prevAll().length;
      active_view = index;
      load_theme(active_theme);
      return set_timers();
    });
    /*
      Update Cards
    
      This is used each time we need to update all the cards on the home page with the new content that's typed in.
      */
    update_cards = function(rowNumber, value) {
      return $('.categories .card').each(function() {
        var $t;
        $t = $(this);
        return $t.find('.line:eq(' + rowNumber + ')').html(value);
      });
    };
    for (i = 0, _ref = $imgs.length; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      $li = $('<li />');
      $my_qr = $('<div class="qr" />');
      $img = $('<img src="/images/biz_card1.png">');
      $my_qr.qr({
        url: 'http://cards.ly/' + Math.random(),
        height: 60,
        width: 60
      });
      $my_qr.css({
        position: 'absolute',
        top: 40,
        left: 180
      });
      $img.css({
        height: 142
      });
      $li.append($my_qr);
      $li.append($img);
      $biz_cards.append($li);
    }
    biz_incr = 142 + 30;
    biz_begin = (-$imgs.length - 1) * biz_incr;
    $biz_cards.css({
      top: biz_begin
    });
    $biz_cards.find('li').hide().fadeIn();
    iterate_num = $imgs.length;
    current_num = 0;
    $loading_screen.hide();
    frame_time = 4000;
    quick_time = 200;
    my_repeatable_function = function() {
      var $guy_im_fading_out, $label_away, $label_to, $my_next_guy, biz_delay, index, style, timer, wait_delay;
      $guy_im_fading_out = $imgs.filter(':eq(' + current_num + ')');
      $my_next_guy = $imgs.filter(':eq(' + (current_num + 1) + ')');
      $label_away = $labels.filter(':eq(' + current_num + ')');
      $label_to = $labels.filter(':eq(' + (current_num + 1) + ')');
      if (!$my_next_guy.length) {
        $my_next_guy = $imgs.filter(':first');
        $label_to = $labels.filter(':first');
      }
      $label_away.stop(true, true).show().css({
        'margin-left': 0
      });
      $label_away.animate({
        'margin-left': -233
      }, quick_time);
      $guy_im_fading_out.stop(true, true).show().css({
        'margin-left': 0
      });
      $guy_im_fading_out.animate({
        'margin-left': -233
      }, quick_time);
      $phone_scanner.stop(true, true);
      $phone_scanner.delay(quick_time).fadeIn(quick_time).delay(quick_time).fadeOut(quick_time);
      wait_delay = quick_time * 3;
      if (wait_delay <= 200) {
        wait_delay = 0;
      }
      $my_next_guy.show().css({
        'margin-left': 233
      });
      $my_next_guy.delay(wait_delay).animate({
        'margin-left': 0
      }, quick_time);
      $label_to.show().css({
        'margin-left': 233
      });
      $label_to.delay(wait_delay).animate({
        'margin-left': 0
      }, quick_time);
      biz_delay = quick_time * 4;
      style = 'swing';
      if (biz_delay <= 200) {
        biz_delay = 0;
        style = 'linear';
      }
      $biz_cards.stop(true, true);
      $biz_cards.delay(biz_delay).animate({
        top: parseInt($biz_cards.css('top')) + biz_incr
      }, frame_time - biz_delay, style);
      current_num++;
      if (current_num === iterate_num) {
        current_num = 0;
      }
      timer = setTimeout(my_repeatable_function, frame_time);
      frame_time = frame_time - 950;
      quick_time = quick_time - 30;
      if (frame_time <= 500) {
        frame_time = frame_time + 850;
        quick_time = 50;
      }
      if (frame_time <= 200) {
        frame_time = 200;
        quick_time = 50;
        index = $my_next_guy.parent().prevAll().length;
        if (index === 0) {
          clearTimeout(timer);
          frame_time = 4000;
          quick_time = 200;
          $biz_cards.stop(true, true).animate({
            top: parseInt($biz_cards.css('top')) + biz_incr * 6
          }, 1200);
          $my_next_guy.fadeOut(500);
          $('.slide:last').delay(500).fadeIn(2000).delay(5500).fadeOut(2000);
          return timer = setTimeout(function() {
            $biz_cards.find('li').hide().fadeIn();
            $biz_cards.stop(true, true).css({
              top: biz_begin
            });
            return my_repeatable_function();
          }, 10000);
        }
      }
    };
    my_repeatable_function();
    /*
      Shopping Cart Stuff
      */
    item_name = '100 cards';
    return $('.checkout').click(function() {
      $.load_alert({
        content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
      });
      return false;
    });
  });
}).call(this);
