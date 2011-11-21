

###

All the stuff for the admin template designer
is probably going to be in this section right here.

ok.

###

$ ->
  $('.new_password').data('timer',0).keyup ->
    $t = $ this
    console.log $t
    clearTimeout $t.data 'timer'
    $t.data 'timer', setTimeout ->
      if $t.val().length >= 4
        $t.removeClass('error').addClass 'valid'
      else
        $t.removeClass('valid').addClass('error').show_tooltip
          message: 'Just '+(4-$t.val().length)+' more characters please.'
    ,1000
  $('.new_password2').data('timer',0).keyup ->
    $t = $ this
    clearTimeout $t.data 'timer'
    $t.data 'timer', setTimeout ->
      if $t.val() == $('.new_password').val()
        $t.removeClass('error').addClass 'valid'
        $('.step_4').fadeTo 300, 1
      else
        $t.removeClass('valid').addClass('error').show_tooltip
          message:'Passwords should match please.'
    ,1000
  false

  #Regular Login
  $('.set_new_password').submit ->
    new_password2 = $('.new_password2').val()
    $.load_loading {}, (loading_close) ->
      err = false
      if $old.password.val() != req.user.password_encrypted
        err = 'Please Enter the correct current password'
      else if $new_password.val() == '' || $new_password2.val() == ''
        err = 'Please enter your new password twice.'
      else if $new_password.val() != $new_password2.val()
        err = 'I\'m sorry, I don\'t think those passwords match.'
      else if $new_password.val().length<4
        err = 'Password should be a little longer, at least 4 characters.'
      if err
        $.load_alert
          content:err
      else
        $.ajax
          url: '/change-password'
          data: JSON.stringify
            old_password: $('.current_passowrd').val()
            new_password: $('.new_password').val()
          success: (data) ->
            loading_close()
            if data.err
              $.load_alert
                content: data.err
            else
              successful_login()
          error: (err) ->
            loading_close()
            $.load_alert
              content: 'Our apologies. A server error occurred.'
    false
  #Successful Login Function
  
  successful_password_change = ->
    $.load_alert
      content: 'Pasword Changed'