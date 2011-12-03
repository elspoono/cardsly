

###

All the stuff for the admin template designer
is probably going to be in this section right here.

ok.

###

$ ->
  $('.printed').mousedown ->
    $t = $ this
    $o = $t.closest '.order_row'
    order_id = $o.attr 'order_id'
    $s = $o.find '.status'
    $s.html 'Saving...'
    $.ajax
      url: '/update-order-status'
      data: JSON.stringify
        order_id: order_id
        status: 'Printed'
      success: (result) ->
        if result.success
          $s.html 'Printed'
    false
  $('.shipped').click ->
    $t = $ this
    $o = $t.closest '.order_row'
    order_id = $o.attr 'order_id'
    $s = $o.find '.status'
    $s.html 'Saving...'
    $.ajax
      url: '/update-order-status'
      data: JSON.stringify
        order_id: order_id
        status: 'Shipped'
      success: (result) ->
        if result.success
          $s.html 'Shipped'
          $o.delay(500).fadeOut()
    false