
  /*
  
  All the stuff for the admin template designer
  is probably going to be in this section right here.
  
  ok.
  */

  $(function() {
    $('.new_password').data('timer', 0).keyup(function() {
      var $t;
      $t = $(this);
      console.log($t);
      clearTimeout($t.data('timer'));
      return $t.data('timer', setTimeout(function() {
        if ($t.val().length >= 4) {
          return $t.removeClass('error').addClass('valid');
        } else {
          return $t.removeClass('valid').addClass('error').show_tooltip({
            message: 'Just ' + (4 - $t.val().length) + ' more characters please.'
          });
        }
      }, 1000));
    });
    $('.new_password2').data('timer', 0).keyup(function() {
      var $t;
      $t = $(this);
      clearTimeout($t.data('timer'));
      return $t.data('timer', setTimeout(function() {
        if ($t.val() === $('.new_password').val()) {
          $t.removeClass('error').addClass('valid');
          return $('.step_4').fadeTo(300, 1);
        } else {
          return $t.removeClass('valid').addClass('error').show_tooltip({
            message: 'Passwords should match please.'
          });
        }
      }, 1000));
    });
    return false;
  });
