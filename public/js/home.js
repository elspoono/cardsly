
  $(function() {
    var $biz_cards, $screens, $slides, start_animation;
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
    return start_animation();
  });
