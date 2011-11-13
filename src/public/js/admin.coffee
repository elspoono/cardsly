

###

All the stuff for the admin template designer
is probably going to be in this section right here.

ok.

###

$ ->

  #############
  #
  # Instanstiate all of our jQuery objects we'll be reusing
  #
  # Grab all the guys we're going to use
  $designer = $ '.designer'
  #
  # Containers
  $options = $designer.find '.options'
  $card = $designer.find '.card'
  $body = $ 'body'
  #
  # Stuff inside the designer itself
  $qr = $card.find '.qr'
  $qr_bg = $qr.find('.background')
  $lines = $card.find '.line'
  #
  # Main Options
  $cat = $designer.find '.category_field input'
  $color1 = $designer.find '.color1'
  $color2 = $designer.find '.color2'
  #
  # Font Options
  $fonts = $designer.find '.font_style'
  $font_color = $fonts.find '.font_color'
  $font_family = $fonts.find '.font_family'
  #
  # QR Options
  $qrs = $designer.find '.qr_style'
  $qr_color1 = $qrs.find '.qr_color1'
  $qr_color2 = $qrs.find '.qr_color2'
  $qr_radius = $qrs.find '.qr_radius'
  $qr_color2_alpha = $qrs.find '.qr_color2_alpha'
  #
  # All Color Pickers
  $all_colors = $ '.color'
  #
  # The form
  $dForm = $designer.find 'form'
  $upload = $dForm.find '[type=file]'
  #
  #
  ################


  # Set some constants
  card_height = $card.outerHeight()
  card_width = $card.outerWidth()
  card_inner_height = $card.height()
  card_inner_width = $card.width()
  active_theme = false
  shift_pressed = false
  ctrl_pressed = false
  history = []
  redo_history = []
  #
  
  ##############
  #
  # GOOGLE FONTS
  #
  # 1. Load them
  # 2. Make their common names available
  #
  #
  # Loading Them
  setTimeout ->
    WebFont.load google:
      families: [ "IM+Fell+English+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin" ]
  ,3000
  #
  # Common Names
  font_families = ['Arial','Comic Sans MS','Courier New','Georgia','Impact','Times New Roman','Trebuchet MS','Verdana','IM Fell English SC','Julee','Syncopate','Gravitas One','Quicksand','Vast Shadow','Smokum','Ovo','Amatic SC','Rancho','Poly','Chivo','Prata','Abril Fatface','Ultra','Love Ya Like A Sister','Carter One','Luckiest Guy','Gruppo','Slackey'].sort()
  #
  # Load in those font families
  $font_family.find('option').remove()
  for fam in font_families
    $font_family.append '<option value="' + fam + '" style="font-family:' + fam + ';">' + fam + '</option>'
  #
  # END GOOGLE FONTS
  #
  ################





  #
  # QRs and Lines are hidden By default
  $qr.hide()
  $lines.hide()

  #
  # QR Code
  qrcode = new QRCode -1, QRErrorCorrectLevel.H
  qrcode.addData 'http://cards.ly'
  qrcode.make()

  # Prep the variables for the canvas
  count = qrcode.getModuleCount()
  scale = 3
  size = count * scale + scale * 2

  $canvas = $ '<canvas height=' + size + ' width=' + size + ' />'
  $qr.css
    height: size
    width: size
  if typeof G_vmlCanvasManager != 'undefined'
    G_vmlCanvasManager.initElement $canvas[0]
  ctx = $canvas[0].getContext "2d"

  update_qr_color = (hex) ->
    
    hexToR = (h) -> parseInt((cutHex(h)).substring(0,2),16)
    hexToG = (h) -> parseInt((cutHex(h)).substring(2,4),16)
    hexToB = (h) -> parseInt((cutHex(h)).substring(4,6),16)
    cutHex = (h) -> if h.charAt(0)=="#" then h.substring(1,7) else h

    ctx.fillStyle = 'rgb(' + hexToR(hex) + ',' + hexToG(hex) + ',' + hexToB(hex) + ')'

    # Actual Drawing of the QR Code
    for r in [0..count-1]
      for c in [0..count-1]
        ctx.fillRect r * scale + scale, c * scale + scale, scale, scale if qrcode.isDark(c,r)
  
  $qr.append $canvas



  #############################
  #
  # The KEYBOARD events
  #
  #
  # Key up and down events for active lines
  shift_amount = 1
  $body.keydown (e) ->
    $active_items = $card.find '.active'
    c = e.keyCode
    #
    # Modify the amount we shift when the shift key is pressed
    if e.keyCode is 16
      shift_pressed = true
      shift_amount = 10
    #
    # Ctrl or Command Pressed Down
    if e.keyCode is 17 or e.keyCode is 91 or e.keyCode is 93
      ctrl_pressed = true
    #
    #
    # Undo 
    if ctrl_pressed and not shift_pressed and e.keyCode is 90
      current_theme = history.pop()
      new_theme = history[history.length-1]
      if new_theme
        redo_history.push current_theme
        load_theme new_theme
      else
        history.push current_theme
        if $('.modal').length is 0
          $.load_alert
            content: 'No more to undo'
    #
    # Redo
    if ctrl_pressed and shift_pressed and e.keyCode is 90
      new_theme = redo_history.pop()
      if new_theme
        history.push new_theme
        load_theme new_theme
      else
        redo_history.push new_theme
        if $('.modal').length is 0
          $.load_alert
            content: 'No more to redo'
    #
    #
    #
    #
    # Only if we have a live one, do we do anything with this
    if $active_items.length and not $font_family.is(':focus') #and not $font_color.is(':focus')
      $active_items.each ->
        $active_item = $ this
        #
        # Up and Down Events
        if c is 38 or c is 40
          #
          # Find out how far the user asked to move
          new_top = parseInt($active_item.css('top'))
          if c is 38 then new_top -= shift_amount
          if c is 40 then new_top += shift_amount
          #
          # Find out our boundary
          top_bound = (card_height - card_inner_height)/2
          bottom_bound = top_bound + card_inner_height - $active_item.outerHeight()
          #
          # And then of course, "bound" it
          # We want to move clear to the max, so we still do it
          if new_top < top_bound then new_top = top_bound
          if new_top > bottom_bound then new_top = bottom_bound
          #
          # Then set it
          $active_item.css 'top', new_top
        #
        # Left and Right
        if c is 37 or c is 39
          #
          # Find out how far the user asked to move
          new_left = parseInt($active_item.css('left'))
          if c is 37 then new_left -= shift_amount
          if c is 39 then new_left += shift_amount
          #
          # Find out our boundary
          top_bound = (card_width - card_inner_width)/2
          bottom_bound = top_bound + card_inner_width - $active_item.outerWidth()
          #
          # And then of course, "bound" it
          # We want to move clear to the max, so we still do it
          if new_left < top_bound then new_left = top_bound
          if new_left > bottom_bound then new_left = bottom_bound
          #
          # Then set it
          $active_item.css 'left', new_left
      #
      # Always return false on the arrow key presses
      if c is 38 or c is 40 or c is 39 or c is 37 then return false
  $body.keyup (e) ->
    if e.keyCode is 17 or e.keyCode is 91 or e.keyCode is 93
      ctrl_pressed = false
    if e.keyCode is 16
      shift_amount = 1
      shift_pressed = false
  #
  #
  #
  ##########################



  # ***************************************************************
  # *
  # *
  # * All of the options making them do functional things
  # *
  # *
  # *

  ##############
  # Colors pickers for ... ... .... ... picking colors.
  #

  $all_colors.each ->
    $t = $ this
    $t.bind 'color_update', (e, options) ->
      $t.data
        hex: options.hex
      $t.css
        background: '#' + options.hex
    $t.focus ->
      $t.ColorPickerSetColor $t.val()
    $t.ColorPicker
      livePreview: true
      onChange: (hsb, hex, rgb) ->
        $t.trigger 'color_update'
          hex: hex
          timer: true
      onShow: (colpkr) ->
        $t.blur()
        
  #
  ###############

  #############
  #
  # Actual triggers from those color pickers to do real stuff
  #
  # Changing font color on key presses
  $font_color.bind 'color_update', (e, options) ->
    $t = $ this
    $active_items = $card.find '.active'
    $active_items.each ->
      $active_item = $ this
      #
      # Update it all
      $active_item.css
        color: '#' + options.hex
      #
      # Find it's index relative to it's peers
      index = $active_item.prevAll().length
      active_theme.positions[index].color = options.hex
    set_timers() if options.timer
  #
  # Changing QR Color on key presses
  $qr_color1.bind 'color_update', (e, options) ->
    update_qr_color options.hex
    set_timers() if options.timer
  #
  $qr_color2.bind 'color_update', (e, options) ->
    $qr_bg.css
      background: '#' + options.hex
    set_timers() if options.timer
  #
  #
  ##############


  ###############
  # Changing font family on select change
  #
  update_family = ->
    $t = $ this
    $active_items = $card.find '.active'
    $active_items.each ->
      $active_item = $ this
      #
      # Update it all
      $active_item.css
        'font-family': $t.val()
      #
      # Find it's index relative to it's peers
      index = $active_item.prevAll().length
      active_theme.positions[index].font_family = $t.val()
    set_timers()
  #
  $font_family.change update_family
  #
  ##############


  ###############
  # Changing alignment for those thumbnail guys
  #
  update_align = (align) ->
    $t = $ this
    $active_items = $card.find '.active'
    $active_items.each ->
      $active_item = $ this
      #
      # Update it all
      $active_item.css
        'text-align': align
      #
      # Find it's index relative to it's peers
      index = $active_item.prevAll().length
      active_theme.positions[index].font_family = align
  #
  $fonts.find('.left').click -> update_align 'left'
  $fonts.find('.center').click -> update_align 'center'
  $fonts.find('.right').click -> update_align 'right'
  #
  ##############



  ###############
  # Changing QR Extras
  #
  $qr_color2_alpha.change ->
    $t = $ this
    $qr_bg.fadeTo 0, $t.val()
    active_theme.qr_color2_alpha = $t.val()
    set_timers()
  #
  $qr_radius.change ->
    $t = $ this
    $qr_bg.css
      'border-radius': $t.val() + 'px'
    active_theme.qr_radius = $t.val()
    set_timers()
  #
  ##############

  # *
  # *
  # * END Options doing functional things
  # *
  # *
  # *
  # ***************************************************************




  ##############
  #
  # Changing Tabs
  #
  # Changing "tabs" (different options for editing)
  change_tab = (tab_class) ->
    $t = $options.find tab_class
    $a = $options.find '.active'
    if $t[0] != $a[0]
      $a.find('ul').stop(true,true).slideUp()
      $a.removeClass 'active'
      $t.find('ul').stop(true,true).slideDown()
      $t.addClass 'active'
  #
  # 
  # Changing to the font tab when it's clicked
  $fonts.find('h4').click ->
    change_tab '.font_style'
    $lines.first().mousedown()
    $lines.filter(':visible').addClass 'active'
    false
  #
  # 
  # Changing to the QR tab when it's clicked
  $qrs.find('h4').click -> 
    $qr.mousedown()
    false
  #
  #####################


  ####################
  #
  # Highlighting helper functions
  #
  # Helper function for highlighting going away
  unfocus_highlight = (e) ->
    $t = $ e.target
    if $t.hasClass('font_style') or $t.closest('.font_style').length or $t.hasClass('qr_style') or $t.closest('.qr_style').length or $t.hasClass('line') or $t.hasClass('qr') or $t.closest('.line').length or $t.closest('.qr').length or $t.closest('.colorpicker').length
      $t = null
    else
      $card.find('.active').removeClass 'active'
      $body.unbind 'click', unfocus_highlight
      change_tab '.defaults'
      return false
  #
  # Highlighting and making a line the active one
  $lines.mousedown (e) ->
    #
    # Set it up and make it active
    $t = $ this
    $pa = $card.find '.active'
    $pa.removeClass 'active' if not shift_pressed
    $t.addClass 'active'
    #
    # Allow body clicks to unfocus it
    $body.bind 'click', unfocus_highlight
    #
    # Find it's index relative to it's peers
    change_tab '.font_style'
    index = $t.prevAll().length
    $font_family[0].selectedIndex = null
    $font_color.trigger 'color_update'
      hex: active_theme.positions[index].color
    $selected = $font_family.find('option[value="' + active_theme.positions[index].font_family + '"]')
    $selected.focus().attr 'selected', 'selected'
  #
  # Highlighting and making a line the active one
  $qr.mousedown ->
    $t = $ this
    $pa = $card.find '.active'
    $pa.removeClass 'active'
    $t.addClass 'active'
    $body.bind 'click', unfocus_highlight
    change_tab '.qr_style'
  #
  #
  ####################

  ####################
  #
  # A global page timer for the automatic save event.
  save_timer = 0
  history_timer = 0
  set_timers = ->
    clearTimeout save_timer
    save_timer = setTimeout ->
      execute_save()
    , 2000
    clearTimeout history_timer
    history_timer = setTimeout ->
      update_active_theme()
      history.push active_theme
      redo_history = []
    , 500

  #
  # Set that timer on the right events for the right things
  $cat.keyup set_timers
  #
  ######################


  #
  # The dragging and dropping functions for lines
  $lines.draggable
    grid: [10,10]
    containment: '.designer .card'
    stop: set_timers
  $lines.resizable
    grid: 10
    handles: 'e, s, se'
    resize: (e, ui) ->
      $t = $(ui.element)
      h = $t.height()
      $t.css
        'font-size': h + 'px'
        'line-height': h + 'px'
    stop: set_timers
  #
  # Dragging and dropping functions for the qr code
  $qr.draggable
    grid: [10,10]
    containment: '.designer .card'
    stop: set_timers
  $qr.resizable
    grid: 10
    resize: (e, ui) ->
        $t = $(ui.element)
        h = $t.height()
        w = $t.width()
        $t.find('canvas').css
          height: h
          width: w
        $t.find('.background').css
          height: h
          width: w
        
    containment: '.designer .card'
    handles: 'se'
    aspectRatio: 1
    stop: set_timers
  #

  #
  # On upload selection, submit that form
  $upload.change ->
    $dForm.submit()

  #
  # 6 and 12 selectors in the thumbnails
  $('.theme_1,.theme_2').click ->
    $t = $ this
    $c = $t.closest '.card'

    $c.click()

    # Actual Switch the classes
    $('.theme_1,.theme_2').removeClass 'active'
    $t.addClass 'active'

    # always return false to prevent href from going anywhere
    false

  #
  # Helper Function for getting the position in percentage from an elements top, left, height and width
  get_position = ($t, previous) ->
    # Get it's CSS Values
    height = parseInt $t.height()
    width = parseInt $t.width()
    left = parseInt $t.css 'left'
    top = parseInt $t.css 'top'
    #
    # Stop me if something went wrong :)
    if isNaN(height) or isNaN(width) or isNaN(top) or isNaN(left)
       return false
    #
    # Calculate a percentage and send it
    result = 
      h: Math.round(height / card_height * 10000) / 100
      w: Math.round(width / card_width * 10000) / 100
      x: Math.round(left / card_width * 10000) / 100
      y: Math.round(top / card_height * 10000) / 100
      text_align: previous.text_align
      color: previous.color
      font_family: previous.font_family
  #
  #
  # Helper function to get the active them stuff before history and before save
  update_active_theme = ->
    # Get the position of the qr
    qr = get_position $qr, {}
    #
    # Set the theme start
    theme =
      _id: active_theme._id
      category: $cat.val()
      qr_x: qr.x
      qr_y: qr.y
      qr_h: qr.h
      qr_w: qr.w
      positions: []
      color1: $color1.data 'hex'
      color2: $color2.data 'hex'
      qr_color1: $qr_color1.data 'hex'
      qr_color2: $qr_color2.data 'hex'
      s3_id: active_theme.s3_id
      qr_radius: active_theme.qr_radius
      qr_color2_alpha: active_theme.qr_color2_alpha
    #
    #
    # Get the position of each line
    $lines.each (i) ->
      $t = $ this
      pos = get_position $t, active_theme.positions[i] || {}
      if pos
        theme.positions.push pos
    #
    #
    active_theme = theme
  #
  # Do the actual save.
  #
  # It should be noted, that in most cases, this just means saving into the session
  # Only on save button click does it pass an extra parameter to save it to a record in the database
  execute_save = (next) ->
    #
    update_active_theme()
    #
    # Set the parameters
    parameters =
      theme: active_theme
      do_save: if next then true else false
    #
    $.ajax
      url: '/saveTheme'
      #
      # jQuery's default data parser does well with simple objects, but with complex ones it doesn't do quite what we need.
      # So in this case, we need to stringify first, doing our own conversion to a string to transmit across the 
      # interwebs to our server.
      #
      # (and correspondingly, the server does a JSON parse of the raw body instead of it's usual parsing.)
      data: JSON.stringify parameters
      success: (serverResponse) ->
        if !serverResponse.success
          $designer.find('.save').showTooltip
            message: 'Error saving.'
        if next then next()
      error: ->
        $designer.find('.save').showTooltip
          message: 'Error saving.'
        if next then next()


  #
  # This catches the script parent.window call sent from app.coffee on the s3 form submit
  $.s3_result = (s3_id) ->
    if not no_theme() and s3_id
      active_theme.s3_id = s3_id
      set_timers()
      $card.css
        background: 'url(\'http://cdn.cards.ly/525x300/' + s3_id + '\')'
    else
      $.load_alert
        content: 'I had trouble saving that image, please try again later.'

  #
  # Function that is called to verify a theme is selected, warns if not.
  no_theme = ->
    if !active_theme
      $.load_alert
        content: 'Please create or select a theme first'
      true
    else
      false

  #
  # Default Template for Card Designer
  default_theme = 
    category: ''
    color1: 'FFFFFF'
    color2: '000000'
    s3_id: ''
    qr_color1: '000066'
    qr_color2: 'FFFFFF'
    qr_color2_alpha: .9
    qr_radius: 10
    qr_h: 50
    qr_w: 28.57
    qr_x: 68.76
    qr_y: 43.33
    positions: []
  for i in [0..5]
    default_theme.positions.push
      color: '000066'
      font_family: 'Vast Shadow'
      text_align: 'left'
      h: 6.67
      w: 60
      x: 3.05
      y: 5+i*10
  #
  # The general load theme function
  # It's for putting a theme into the designer for editing
  load_theme = (theme) ->
    #
    # set this theme as the active_theme
    active_theme = theme
    #
    # Show the qr code and set it to the right place
    $qr.show().css
      top: theme.qr_y/100 * card_height
      left: theme.qr_x/100 * card_width
      height: theme.qr_h/100 * card_height
      width: theme.qr_h/100 * card_height
    $qr.find('canvas').css
      height: theme.qr_h/100 * card_height
      width: theme.qr_h/100 * card_height
    $qr_bg.css
      'border-radius': theme.qr_radius+'px'
      height: theme.qr_h/100 * card_height
      width: theme.qr_h/100 * card_height
      background: '#'+theme.qr_color2
    $qr_bg.fadeTo 0, theme.qr_color2_alpha
    update_qr_color theme.qr_color1
    #
    # Card Background
    if theme.s3_id
      $card.css
        background: '#FFFFFF url(\'http://cdn.cards.ly/525x300/' + theme.s3_id + '\')'
    else
      $card.css
        background: '#FFFFFF'
    #
    # Move all the lines and their shit
    for pos,i in theme.positions
      $li = $lines.eq i
      $li.show().css
        top: pos.y/100 * card_height
        left: pos.x/100 * card_width
        width: (pos.w/100 * card_width) + 'px'
        fontSize: (pos.h/100 * card_height) + 'px'
        lineHeight: (pos.h/100 * card_height) + 'px'
        fontFamily: pos.font_family
        textAlign: pos.text_align
        color: '#'+pos.color
    $cat.val theme.category
    #
    # Set all the colors
    $color1.trigger 'color_update'
      hex: theme.color1
    $color2.trigger 'color_update'
      hex: theme.color2
    $qr_color1.trigger 'color_update'
      hex: theme.qr_color1
    $qr_color2.trigger 'color_update'
      hex: theme.qr_color2
    #
    # Get the QR alpha and radius ready
    $qr_color2_alpha.find('[value="' + theme.qr_color2_alpha + '"]').attr 'selected', 'selected'
    $qr_radius.find('[value=' + theme.qr_radius + ']').attr 'selected', 'selected'
  #
  # The add new button
  $('.add_new').click ->
    #
    # Restart the history
    theme = default_theme
    history = [theme]
    #
    # Load it up
    load_theme(theme)
  #
  #
  # On save click
  $designer.find('.buttons .save').click ->
    # Make sure we have something selected.
    if no_theme() then return false
    
    $.load_loading {}, (close_loading) ->
      execute_save ->
        close_loading()
  #
  # On delete click
  $designer.find('.buttons .delete').click ->
    if no_theme() then return false
    $.load_modal
      content: '<p>Are you sure you want to permanently delete this template?</p>'
      height: 160
      width: 440
      buttons: [{
        label: 'Delete'
        action: (close_func) ->
          ###
          TODO: Make this delete the template

          So send to the server to delete the template we're on here ...

          ###
          close_func()
        },{
        class: 'gray'
        label: 'Cancel'
        action: (close_func) ->
          close_func()
        }
      ]
  