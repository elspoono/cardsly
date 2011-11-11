

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