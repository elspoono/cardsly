
  /*
  
  All the stuff for the admin template designer
  is probably going to be in this section right here.
  
  ok.
  */

  $(function() {
    var $new_password, $new_password2, $old_password, $set_new_password, successful_password_change;
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
    false;
    $old_password = $('.current_password');
    $set_new_password = $('.set_new_password');
    $new_password = $('.new_password');
    $new_password2 = $('.new_password2');
    $set_new_password.submit(function() {
      var err;
      err = false;
      if ($old.password.val() !== req.user.password_encrypted) {
        err = 'Please Enter the correct current password';
      }
      if ($new_password.val() === '' || $new_password2.val() === '') {
        err = 'Please enter your new password twice.';
      } else if ($new_password.val() !== $new_password2.val()) {
        err = 'I\'m sorry, I don\'t think those passwords match.';
      } else if ($new_password.val().length < 4) {
        err = 'Password should be a little longer, at least 4 characters.';
      }
      if (err) {
        $.load_alert({
          content: err
        });
      } else {
        $.load_loading({}, function(loading_close) {
          return $.ajax({
            url: '/change-password',
            data: JSON.stringify({
              new_password: $new_password.val(),
              new_password2: $new_password2.val()
            }),
            success: function(data) {
              loading_close();
              if (data.err) {
                return $.load_alert({
                  content: data.err
                });
              } else {
                return successful_password_change();
              }
            },
            error: function(err) {
              loading_close();
              return $.load_alert({
                content: 'Our apologies. A server error occurred.'
              });
            }
          });
        });
      }
      return false;
    });
    return successful_password_change = function() {
      return $.load_alert({
        content: 'Pasword Changed'
      });
    };
  });
