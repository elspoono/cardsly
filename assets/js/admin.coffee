##################################################################

###

Theme admin

- All the theme designer stuff

- Plus maybe some similar stuff to home page gallery selection

###

##################################################################






$ ->
  #############
  #
  #
  #
  #
  #
  # Instanstiate all of our jQuery objects we'll be reusing
  #
  # Grab all the guys we're going to use
  $designer = $ '.designer'
  #
  #
  # Containers
  $options = $designer.find '.options'
  $card = $designer.find '.card'
  $body = $ 'body'
  $categories = $ '.categories'
  #
  # Stuff inside the designer itself
  $qr = $card.find '.qr'
  $qr_bg = $qr.find '.background'
  $content = $card.find '.content'
  $content.append('<div class="line">' + line + '</div>') for line in $.line_copy
  $lines = $content.find '.line'
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
  $font_size_indicator = $fonts.find '.indicator'
  $font_size_slider = $fonts.find '.size .slider'
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
  #
  $web_fg = $ '.web_fg'
  $web_fg2 = $ '.web_fg2'
  $web_bg = $ '.web_bg'
  #
  $save_button = $designer.find '.buttons .save'
  #
  #
  $views = $designer.find '.views'
  $twelve_button = $views.find '.twelve'
  $web_button = $views.find '.web'
  $six_button = $views.find '.six'
  #
  #
  # The form
  $dForm = $designer.find 'form'
  $upload = $dForm.find '[type=file]'
  #
  #
  ################
  #
  #
  # Set some constants
  active_theme = false
  active_view = 0
  shift_pressed = false
  ctrl_pressed = false
  history = []
  redo_history = []
  card_height = 0
  card_width = 0
  card_inner_height = 0
  card_inner_width = 0
  update_card_size = ->
    card_height = $card.outerHeight()
    card_width = $card.outerWidth()
    card_inner_height = $card.height()
    card_inner_width = $card.width()
  update_card_size()
  #
  #
  #
  #
  #
  ########################################################################








  ##############
  #
  # The Themes
  #
  $.ajax
    url: '/get-themes'
    success: (all_data) ->
      all_themes = all_data.themes
      $categories.html ''
      for theme in all_themes
        #
        #
        #
        $my_card = $.create_card_from_theme
          theme: theme
        
        # Push the whole thing to categories
        $.add_card_to_category $my_card, theme
      #
      #
      # Click the first theme
      $categories.find('.category:first h4').click()

    error: ->
      $.load_alert
        content: 'Error loading themes. Please try again later.'
  $('.category .card').live 'click', () ->
    $t = $ this
    theme = $t.data 'theme'
    if active_theme._id
      $a = $ '.category .card'
      $a.each ->
        $t = $ this
        if $t.data('theme') and $t.data('theme')._id == active_theme._id
          $t.data 'theme', active_theme
    if theme
      load_theme theme
      history = [$.extend true, {}, active_theme]
  #
  #
  #
  #
  #
  #
  # END The Themes
  #
  #
  ##############










  ##############
  #
  # GOOGLE FONTS
  #
  # 1. Load them
  # 2. Make their common names available
  #
  #
  # Common Names
  font_families = ['Arial','Comic Sans MS','Courier New','Georgia','Impact','Times New Roman','Trebuchet MS','Verdana','IM FELL English SC','Julee','Syncopate','Gravitas One','Quicksand','Vast Shadow','Smokum','Ovo','Amatic SC','Rancho','Poly','Chivo','Prata','Abril Fatface','Ultra','Love Ya Like A Sister','Carter One','Luckiest Guy','Gruppo','Slackey'].sort()
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
  $web_fg.hide()
  $web_fg2.hide()
  $web_bg.hide()
  
  #$qr.prep_qr()


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
      e.preventDefault()
      current_theme = history.pop()
      new_theme = history[history.length-1]
      if new_theme
        redo_history.push $.extend true, {}, current_theme
        load_theme new_theme
      else
        history.push $.extend true, {}, current_theme
    #
    # Redo
    if ctrl_pressed and shift_pressed and e.keyCode is 90
      e.preventDefault()
      new_theme = redo_history.pop()
      if new_theme
        history.push $.extend true, {}, new_theme
        load_theme new_theme
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
          #
          set_timers()
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
          #
          set_timers()
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
    $t.ColorPicker
      livePreview: true
      onChange: (hsb, hex, rgb) ->
        $t.trigger 'color_update'
          hex: hex
          rgb: rgb
          timer: true
      onShow: (colpkr) ->
        $t.ColorPickerSetColor $t.data 'hex'     
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
      active_theme.theme_templates[active_view].lines[index].color = options.hex
    set_timers() if options.timer
  #
  # Changing QR Color on key presses
  $qr_color1.bind 'color_update', (e, options) ->
    $qr.qr
      color: options.hex
      height: active_theme.theme_templates[active_view].qr.height/100 * card_height
      width: active_theme.theme_templates[active_view].qr.height/100 * card_height
    set_timers() if options.timer
  #
  $qr_color2.bind 'color_update', (e, options) ->
    $qr_bg.css
      background: '#' + options.hex
    set_timers() if options.timer
  #
  #
  $color2.bind 'color_update', (e, options) ->
    $web_bg.css
      background: '#' + options.hex
  #
  $color1.bind 'color_update', (e, options) ->
    #add_transparent_gradient options.hex, '40%', $web_fg
    #add_transparent_gradient options.hex, '80%', $web_fg2
    

  #
  #
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
      active_theme.theme_templates[active_view].lines[index].font_family = $t.val()
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
      active_theme.theme_templates[active_view].lines[index].text_align = align
      set_timers()
  #
  $fonts.find('.left').click -> update_align 'left'
  $fonts.find('.center').click -> update_align 'center'
  $fonts.find('.right').click -> update_align 'right'
  #
  ##############


  ###############
  # Changing font size for those thumbnail guys
  #
  update_active_size = (new_h) ->
    $active_items = $card.find '.active'
    $active_items.each ->
      $active_item = $ this
      #
      #
      # Update it all
      $active_item.css
        'font-size': new_h + 'px'
        'line-height': new_h + 'px'
        'height': new_h + 'px'
      #
    $font_size_indicator.html new_h
    $font_size_slider.slider 'value', new_h

  update_size = (size_change) ->
    $t = $ this
    #
    $active_items = $card.find '.active'
    h = $active_items.height()
    #
    new_h = h + size_change
    #
    update_active_size new_h
    #
    set_timers()
  #
  $fonts.find('.increase').click -> update_size 1
  $fonts.find('.decrease').click -> update_size -1
  $font_size_slider.slider
    min: 1
    max: 75
    step: 5
    slide: (e, ui) ->
      #
      update_active_size ui.value
      #
      set_timers()
  #
  ##############



  ###############
  # Changing QR Extras
  #
  $qr_color2_alpha.slider
    min: 0
    max: 100
    step: 5
    slide: (e, ui) ->
      #
      $qr_bg.fadeTo 0, ui.value/100
      active_theme.theme_templates[active_view].qr.color2_alpha = ui.value/100
      set_timers()
  #
  $qr_radius.change ->
    $t = $ this
    $qr_bg.css
      'border-radius': $t.val() + 'px'
    active_theme.theme_templates[active_view].qr.radius = $t.val()
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
  #
  # Highlighting and making a line the active one
  $lines.mousedown (e) ->
    #
    # Set it up and make it active
    $t = $ this
    new_h = $t.height()
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
      hex: active_theme.theme_templates[active_view].lines[index].color
    $selected = $font_family.find('option[value="' + active_theme.theme_templates[active_view].lines[index].font_family + '"]')
    $selected.focus().attr 'selected', 'selected'
    #
    #
    $font_size_indicator.html new_h
    $font_size_slider.slider 'value', new_h
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
    clearTimeout history_timer
    history_timer = setTimeout ->
      update_active_theme()
      history.push $.extend true, {}, active_theme
      redo_history = []
      if not active_theme.not_saved
        active_theme.not_saved = true 
        $save_button.stop(true,true).slideDown()
    , 200
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
      update_active_size h
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
  # Helper Function for getting the position in percentage from an elements top, left, height and width
  get_position = ($t) ->
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
  #
  #
  # Helper function to get the active them stuff before history and before save
  update_active_theme = ->
    # Get the position of the qr
    qr_pos = get_position $qr
    #
    # Set the theme start
    active_theme.category = $cat.val()
    active_theme.theme_templates[active_view].color1 = $color1.data 'hex'
    active_theme.theme_templates[active_view].color2 = $color2.data 'hex'
    active_theme.theme_templates[active_view].qr =
      x: qr_pos.x
      y: qr_pos.y
      h: qr_pos.h
      w: qr_pos.w
      color1: $qr_color1.data 'hex'
      color2: $qr_color2.data 'hex'
      color2_alpha: active_theme.theme_templates[active_view].qr.color2_alpha
      radius: active_theme.theme_templates[active_view].qr.radius
    #
    #
    for line,i in active_theme.theme_templates[active_view].lines
      line_pos = get_position $lines.filter ':eq(' + i + ')'
      active_theme.theme_templates[active_view].lines[i] =
        x: line_pos.x
        y: line_pos.y
        h: line_pos.h
        w: line_pos.w
        color: line.color
        font_family: line.font_family
        text_align: line.text_align
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
      url: '/save-theme'
      #
      # jQuery's default data parser does well with simple objects, but with complex ones it doesn't do quite what we need.
      # So in this case, we need to stringify first, doing our own conversion to a string to transmit across the 
      # interwebs to our server.
      #
      # (and correspondingly, the server does a JSON parse of the raw body instead of it's usual parsing.)
      data: JSON.stringify parameters
      success: (serverResponse) ->
        if !serverResponse.success
          $designer.find('.save').show_tooltip
            message: 'Error saving.'
        if next then next serverResponse
      error: ->
        $designer.find('.save').show_tooltip
          message: 'Error saving.'
        if next then next()
  #
  # This catches the script parent.window call sent from app.coffee on the s3 form submit
  $.s3_result = (s3_id) ->
    if not no_theme() and s3_id
      active_theme.theme_templates[active_view].s3_id = s3_id
      active_theme.s3_id = s3_id
      set_timers()
      $card.css
        background: 'url(\'//d3eo3eito2cquu.cloudfront.net/525x300/' + s3_id + '\')'
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
    not_saved: true
    s3_id = ''
    theme_templates: [
      color1: 'FFFFFF'
      color2: '000000'
      s3_id: ''
      qr:
        color1: '000066'
        color2: 'FFFFFF'
        color2_alpha: .9
        radius: 10
        h: 50
        w: 28.57
        x: 68.76
        y: 43.33
      lines:
        (color: '000066'
        font_family: 'Vast Shadow'
        text_align: 'left'
        h: 6.67
        w: 60
        x: 3.05
        y: 5+i*10) for i in [0..5]
    ]
  #
  # The general load theme function
  # It's for putting a theme into the designer for editing
  load_theme = (theme) ->
    #
    #
    # Update Test Link
    $('.test_link a').attr 'href', '/test/'+theme._id
    #
    # Set Constants
    theme_template = theme.theme_templates[active_view]
    #
    #
    ###
    #
    Here is where we create the new theme template if none exists
    #
    - if 1 do bleh
    - if 2 do blah
    #
    ###
    if !theme_template
      if active_view is 2
        theme_template = $.extend true, {}, theme.theme_templates[0]
        delete theme_template._id
      if active_view is 1
        theme_template = $.extend true, {}, theme.theme_templates[0]
        delete theme_template._id
        for line in theme_template.lines
          $.extend true, line,
            h: line.h/1.5
            w: line.w/1.5
          new_line = $.extend true, {}, line
          new_line.x = 100-new_line.x-new_line.w
          theme_template.lines.push new_line
        theme_template.qr.h = theme_template.qr.h/1.5
        theme_template.qr.w = theme_template.qr.w/1.5
      theme.theme_templates[active_view] = theme_template
    if active_view is 1 and theme.theme_templates[active_view].lines.length > 10
      theme.theme_templates[active_view].lines.splice 10,5
    #
    #
    # show or hide save button
    if theme.not_saved then $save_button.stop(true,true).show() else $save_button.stop(true,true).hide() 
    #
    #
    # set this theme as the active_theme
    active_theme = theme
    #
    #
    #
    #
    # Card Background
    if theme.s3_id
      $card.css
        background: '#FFFFFF url(\'//d3eo3eito2cquu.cloudfront.net/525x300/' + theme.s3_id + '\')'
    else
      $card.css
        background: '#FFFFFF'
    if active_view is 2
      $card.css
      $card.css
        height: 140
        width: 252
        margin: '0 126px'
        padding: 5
        'background-repeat': 'repeat-y'
        'background-size': '100%'
      update_card_size()
      $card.css
        height: 290
      $web_fg.show()
      $web_fg2.show()
      $web_bg.show()
    else
      $card.css
        height: 280
        width: 505
        padding: 10
        margin: 0
      update_card_size()
      $web_fg.hide()
      $web_fg2.hide()
      $web_bg.hide()
    #
    #
    $qr.hide()
    $lines.hide()
    #
    # Show the qr code and set it to the right place
    if active_view is 0 or active_view is 1
      $qr.show().css
        top: theme_template.qr.y/100 * card_height
        left: theme_template.qr.x/100 * card_width
      $qr.find('canvas').css
        height: theme_template.qr.h/100 * card_height
        width: theme_template.qr.h/100 * card_height
      $qr_bg.css
        'border-radius': theme_template.qr.radius+'px'
        height: theme_template.qr.h/100 * card_height
        width: theme_template.qr.w/100 * card_width
        background: '#'+theme_template.qr.color2
      $qr_bg.fadeTo 0, theme_template.qr.color2_alpha
      $qr.qr
        color: theme_template.qr.color1
        height: theme_template.qr.h/100 * card_height
        width: theme_template.qr.h/100 * card_height
    #
    #
    # Move all the lines and their shit
    for pos,i in theme_template.lines
      $li = $lines.eq i
      $li.show().css
        top: pos.y/100 * card_height
        left: pos.x/100 * card_width
        width: (pos.w/100 * card_width) + 'px'
        height: (pos.h/100 * card_height) + 'px'
        fontSize: (pos.h/100 * card_height) + 'px'
        lineHeight: (pos.h/100 * card_height) + 'px'
        fontFamily: pos.font_family
        textAlign: pos.text_align
        color: '#'+pos.color
    $cat.val theme.category
    #
    # Set all the colors
    $color1.trigger 'color_update'
      hex: theme_template.color1
    $color2.trigger 'color_update'
      hex: theme_template.color2
    $qr_color1.trigger 'color_update'
      hex: theme_template.qr.color1
    $qr_color2.trigger 'color_update'
      hex: theme_template.qr.color2
    #
    # Get the QR alpha and radius ready
    $qr_color2_alpha.slider 'value', theme_template.qr.color2_alpha*100
    $qr_radius.find('[value=' + theme_template.qr.radius + ']').attr 'selected', 'selected'
  #
  #
  #
  #
  #
  #
  #
  # The add new button
  $('.add_new').click ->
    #
    #
    # DEEP COPY
    # http://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-clone-a-javascript-object
    #
    # You may need this again :D :D :D
    temp_theme = $.extend true, {}, default_theme
    #
    # Restart the history
    history = [$.extend true, {}, temp_theme]
    #
    # Load it up
    $new_card = $ '<div class="card" />'
    $new_card.css
      background: '#FFF'
    $new_card.data 'theme', temp_theme
    $my_cat = $ '.categories .category[category=]'
    if $my_cat.length is 0
      $my_cat = $ '<div class="category" category=""><h4>(no category)</h4><div class="cards"></div></div>'
      $categories.prepend $my_cat
    $my_cat.find('.cards').prepend $new_card
    $my_cat.find('h4').click()
    $my_cat.find('h4').click()
    $new_card.click()
  #
  #
  #
  $view_buttons = $ '.views .option'
  $view_buttons.unbind().click ->
    $t = $ this
    $view_buttons.filter('.active').removeClass 'active'
    $t.addClass 'active'
    #
    index = $t.prevAll().length
    active_view = index
    #
    load_theme active_theme
  #
  #
  #
  #
  # On save click
  $save_button.click ->
    # Make sure we have something selected.
    if no_theme() then return false
    
    $.load_loading {}, (close_loading) ->
      execute_save (result) ->
        close_loading()
        $new_card = $.create_card_from_theme 
          theme: active_theme
        active_theme.not_saved = false
        active_theme._id = result.theme._id
        $save_button.stop(true,true).slideUp()
        $new_card.addClass 'active'
        $new_card.data 'theme', active_theme
        $('.category .card.active').remove()
        $.add_card_to_category $new_card, active_theme
        $new_card.closest('.category').find('h4').click()
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
          #
          #
          active_theme.active = false
          #
          #
          $.load_loading {}, (close_loading) ->
            execute_save ->
              close_loading()
              $('.category .card.active').remove()
              $('.category:first h4').click()
          close_func()
        },{
        class: 'gray'
        label: 'Cancel'
        action: (close_func) ->
          close_func()
        }
      ]
  