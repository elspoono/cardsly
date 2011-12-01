$ ->
  #Email Password
  $('.email_for_password').submit ->
    err = false
    if $('.current_email').val() is ''
      err =  'Please enter your email address.'
    if err
      $.load_alert {content:err}
    else
      $.load_loading {}, (loading_close) ->
        $.ajax
          url: '/send-password-reset'
          data: JSON.stringify
            email_password: $('.current_email').val()
          success: (data) ->
            loading_close()
            if data.err
              $.load_alert
                content: data.err
            else
              $.load_alert
                content: 'Password Reset Sent'
              $('.set_new_password').replaceWith '<p>Password changes successfully!</p>'
          error: (err) ->
            loading_close()
            $.load_alert
              content: 'Our apologies. A server error occurred.'
    false