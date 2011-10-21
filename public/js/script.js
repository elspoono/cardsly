(function() {
  $(function() {
    return $('.add-button').hover(function() {
      return $(this).addClass('hover');
    }, function() {
      return $(this).removeClass('hover');
    }).mousedown(function() {
      return $(this).addClass('click');
    }).mouseup(function() {
      return $(this).removeClass('click');
    });
  });
}).call(this);
