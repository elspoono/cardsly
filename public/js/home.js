
  /*
  
  This is only for the home page
  
  - Home page animations
  - Gallery selection on the home page
  */

  $(function() {
    var $biz_cards, $body, $img, $imgs, $labels, $li, $loading_screen, $my_qr, $phone_scanner, $slides, biz_begin, biz_incr, current_num, frame_time, i, imagelist, iterate_num, my_repeatable_function, quick_time, _i, _len, _ref;
    $biz_cards = $('.biz_cards');
    $slides = $('.slides');
    $phone_scanner = $('.phone_scanner');
    imagelist = [['derek/facebook.png', 'social'], ['recipe.png', 'recipes'], ['derek/flickr.png', 'photos'], ['video.png', 'videos'], ['derek/twitter.png', 'twitter'], ['derek/linkedin.png', 'linkedIn'], ['derek/wordpress.png', 'blog'], ['derek/tumblr.png', 'tumblr'], ['deal.png', 'deals'], ['derek/ebay.png', 'eBay'], ['derek/etsy.png', 'etsy'], ['derek/deviantart.png', 'art portfolio'], ['map.png', 'maps'], ['xkcd.png', 'web comics'], ['review.png', 'movie reviews'], ['derek/yelp.png', 'yelp'], ['article.png', 'news stories'], ['derek/github.png', 'gitHub'], ['derek/meetup.png', 'meetup']];
    for (_i = 0, _len = imagelist.length; _i < _len; _i++) {
      i = imagelist[_i];
      $slides.append('<li><img src="/images/home/' + i[0] + '" /><label>' + i[1] + '</label></li>');
    }
    $imgs = $slides.find('img');
    $labels = $slides.find('label');
    $loading_screen = $('.loading_screen');
    $imgs.hide();
    $phone_scanner.hide();
    $body = $(document);
    for (i = 0, _ref = $imgs.length; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      $li = $('<li />');
      $my_qr = $('<div class="qr" />');
      $img = $('<img src="/images/home/biz_card.png">');
      $my_qr.qr({
        url: 'http://cards.ly/' + Math.random(),
        height: 44,
        width: 44
      });
      $my_qr.css({
        position: 'absolute',
        top: 56,
        left: 185
      });
      $img.css({
        height: 142
      });
      $li.append($my_qr);
      $li.append($img);
      $biz_cards.append($li);
    }
    biz_incr = 142 + 30;
    biz_begin = (-$imgs.length - .75) * biz_incr;
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
      wait_delay = quick_time * 3;
      if (wait_delay <= 150) wait_delay = 0;
      $label_away.stop(true, true).show().css({
        'margin-left': 0
      });
      $label_away.delay(wait_delay).animate({
        'margin-left': -233
      }, quick_time);
      $guy_im_fading_out.stop(true, true).show().css({
        'margin-left': 0
      });
      $guy_im_fading_out.delay(wait_delay).animate({
        'margin-left': -233
      }, quick_time);
      $phone_scanner.stop(true, false);
      $phone_scanner.fadeIn(quick_time).delay(quick_time).fadeOut(quick_time);
      wait_delay = quick_time * 4;
      if (wait_delay <= 200) wait_delay = 0;
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
      if (current_num === iterate_num) current_num = 0;
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
          $label_to.stop(true, true).css({
            'margin-left': 0
          });
          $label_to.delay(2000).fadeOut(3000);
          $biz_cards.stop(true, true).animate({
            top: parseInt($biz_cards.css('top')) + biz_incr * 6
          }, 1200);
          $my_next_guy.fadeOut(500);
          $('.slide:last').stop(true, true).delay(500).fadeIn(2000).delay(5500).fadeOut(2000);
          return timer = setTimeout(function() {
            $biz_cards.find('li').hide().fadeIn();
            $biz_cards.stop(true, true).css({
              top: biz_begin
            });
            return my_repeatable_function();
          }, 12000);
        }
      }
    };
    return $(window).load(function() {
      if ($.browser.msie && parseInt($.browser.version, 10) < 8) {
        return console.log('Do something for IE7 here');
      } else {
        return my_repeatable_function();
      }
    });
  });
