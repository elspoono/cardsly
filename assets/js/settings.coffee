

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

  #Change Pasword
  $('.set_new_password').submit ->
    err = false
    if $('.new_password').val() is '' or $('.new_password2').val() is ''
      err =  'Please enter your new password twice.'
    else if $('.new_password').val() isnt $('.new_password2').val()
      err = 'I\'m sorry, I don\'t think those passwords match.'
    else if $('.new_password').val() < 4
      err = 'Password should be a little longer, at least 4 characters.'
    else if $('.current_password').val() < 4
      err = 'Please enter your current password.'
    if err
      $.load_alert {content:err}
    else
      $.load_loading {}, (loading_close) ->
        $.ajax
          url: '/change-password'
          data: JSON.stringify
            current_password: $('.current_password').val()
            new_password: $('.new_password').val()
          success: (data) ->
            loading_close()
            if data.err
              $.load_alert
                content: data.err
            else
              $.load_alert
                content: 'Password Successfully Changed!'
              $('.set_new_password').replaceWith '<p>Password changes successfully!</p>'
          error: (err) ->
            loading_close()
            $.load_alert
              content: 'Our apologies. A server error occurred.'
          wrong_password: (wp) ->
            loading_close()
            $.load_alert
              content: 'Please enter the correct current password'

    false