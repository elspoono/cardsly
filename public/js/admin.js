
  /*
  
  Theme admin
  
  - All the theme designer stuff
  
  - Plus maybe some similar stuff to home page gallery selection
  */

  $(function() {
    var $all_colors, $body, $card, $cat, $categories, $color1, $color2, $content, $dForm, $designer, $font_color, $font_family, $font_size_indicator, $font_size_slider, $fonts, $lines, $options, $qr, $qr_bg, $qr_color1, $qr_color2, $qr_color2_alpha, $qr_radius, $qrs, $save_button, $six_button, $twelve_button, $upload, $view_buttons, $views, $web_bg, $web_button, $web_fg, active_theme, active_view, card_height, card_inner_height, card_inner_width, card_width, change_tab, ctrl_pressed, default_theme, execute_save, fam, font_families, get_position, history, history_timer, i, line, load_theme, no_theme, redo_history, save_timer, set_timers, shift_amount, shift_pressed, unfocus_highlight, update_active_size, update_active_theme, update_align, update_card_size, update_family, update_size, _i, _j, _len, _len2, _ref;
    $designer = $('.designer');
    $options = $designer.find('.options');
    $card = $designer.find('.card');
    $body = $('body');
    $categories = $('.categories');
    $qr = $card.find('.qr');
    $qr_bg = $qr.find('.background');
    $content = $card.find('.content');
    _ref = $.line_copy;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      $content.append('<div class="line">' + line + '</div>');
    }
    $lines = $content.find('.line');
    $cat = $designer.find('.category_field input');
    $color1 = $designer.find('.color1');
    $color2 = $designer.find('.color2');
    $fonts = $designer.find('.font_style');
    $font_color = $fonts.find('.font_color');
    $font_family = $fonts.find('.font_family');
    $font_size_indicator = $fonts.find('.indicator');
    $font_size_slider = $fonts.find('.size .slider');
    $qrs = $designer.find('.qr_style');
    $qr_color1 = $qrs.find('.qr_color1');
    $qr_color2 = $qrs.find('.qr_color2');
    $qr_radius = $qrs.find('.qr_radius');
    $qr_color2_alpha = $qrs.find('.qr_color2_alpha');
    $all_colors = $('.color');
    $web_fg = $('.web_fg');
    $web_bg = $('.web_bg');
    $save_button = $designer.find('.buttons .save');
    $views = $designer.find('.views');
    $twelve_button = $views.find('.twelve');
    $web_button = $views.find('.web');
    $six_button = $views.find('.six');
    $dForm = $designer.find('form');
    $upload = $dForm.find('[type=file]');
    active_theme = false;
    active_view = 0;
    shift_pressed = false;
    ctrl_pressed = false;
    history = [];
    redo_history = [];
    card_height = 0;
    card_width = 0;
    card_inner_height = 0;
    card_inner_width = 0;
    update_card_size = function() {
      card_height = $card.outerHeight();
      card_width = $card.outerWidth();
      card_inner_height = $card.height();
      return card_inner_width = $card.width();
    };
    update_card_size();
    $.ajax({
      url: '/get-themes',
      success: function(all_data) {
        var $my_card, all_themes, theme, _j, _len2;
        all_themes = all_data.themes;
        $categories.html('<div class="category" category=""><h4>(no category)</h4></div>');
        for (_j = 0, _len2 = all_themes.length; _j < _len2; _j++) {
          theme = all_themes[_j];
          $my_card = $.create_card_from_theme(theme);
          $.add_card_to_category($my_card, theme);
        }
        return $categories.find('.card:first').click();
      },
      error: function() {
        return $.load_alert({
          content: 'Error loading themes. Please try again later.'
        });
      }
    });
    $('.category .card').live('click', function() {
      var $a, $t, theme;
      $t = $(this);
      theme = $t.data('theme');
      if (active_theme._id) {
        $a = $('.category .card');
        $a.each(function() {
          $t = $(this);
          if ($t.data('theme') && $t.data('theme')._id === active_theme._id) {
            return $t.data('theme', active_theme);
          }
        });
      }
      if (theme) {
        load_theme(theme);
        return history = [theme];
      }
    });
    setTimeout(function() {
      return WebFont.load({
        google: {
          families: ["IM+Fell+English+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin"]
        }
      });
    }, 3000);
    font_families = ['Arial', 'Comic Sans MS', 'Courier New', 'Georgia', 'Impact', 'Times New Roman', 'Trebuchet MS', 'Verdana', 'IM Fell English SC', 'Julee', 'Syncopate', 'Gravitas One', 'Quicksand', 'Vast Shadow', 'Smokum', 'Ovo', 'Amatic SC', 'Rancho', 'Poly', 'Chivo', 'Prata', 'Abril Fatface', 'Ultra', 'Love Ya Like A Sister', 'Carter One', 'Luckiest Guy', 'Gruppo', 'Slackey'].sort();
    $font_family.find('option').remove();
    for (_j = 0, _len2 = font_families.length; _j < _len2; _j++) {
      fam = font_families[_j];
      $font_family.append('<option value="' + fam + '" style="font-family:' + fam + ';">' + fam + '</option>');
    }
    $qr.hide();
    $lines.hide();
    $web_fg.hide();
    $web_bg.hide();
    $qr.prep_qr();
    shift_amount = 1;
    $body.keydown(function(e) {
      var $active_items, c, current_theme, new_theme;
      $active_items = $card.find('.active');
      c = e.keyCode;
      if (e.keyCode === 16) {
        shift_pressed = true;
        shift_amount = 10;
      }
      if (e.keyCode === 17 || e.keyCode === 91 || e.keyCode === 93) {
        ctrl_pressed = true;
      }
      if (ctrl_pressed && !shift_pressed && e.keyCode === 90) {
        current_theme = history.pop();
        new_theme = history[history.length - 1];
        if (new_theme) {
          redo_history.push(current_theme);
          load_theme(new_theme);
        } else {
          history.push(current_theme);
          if ($('.modal').length === 0) {
            $.load_alert({
              content: 'No more to undo'
            });
          }
        }
      }
      if (ctrl_pressed && shift_pressed && e.keyCode === 90) {
        new_theme = redo_history.pop();
        if (new_theme) {
          history.push(new_theme);
          load_theme(new_theme);
        } else {
          redo_history.push(new_theme);
          if ($('.modal').length === 0) {
            $.load_alert({
              content: 'No more to redo'
            });
          }
        }
      }
      if ($active_items.length && !$font_family.is(':focus')) {
        $active_items.each(function() {
          var $active_item, bottom_bound, new_left, new_top, top_bound;
          $active_item = $(this);
          if (c === 38 || c === 40) {
            new_top = parseInt($active_item.css('top'));
            if (c === 38) new_top -= shift_amount;
            if (c === 40) new_top += shift_amount;
            top_bound = (card_height - card_inner_height) / 2;
            bottom_bound = top_bound + card_inner_height - $active_item.outerHeight();
            if (new_top < top_bound) new_top = top_bound;
            if (new_top > bottom_bound) new_top = bottom_bound;
            $active_item.css('top', new_top);
            set_timers();
          }
          if (c === 37 || c === 39) {
            new_left = parseInt($active_item.css('left'));
            if (c === 37) new_left -= shift_amount;
            if (c === 39) new_left += shift_amount;
            top_bound = (card_width - card_inner_width) / 2;
            bottom_bound = top_bound + card_inner_width - $active_item.outerWidth();
            if (new_left < top_bound) new_left = top_bound;
            if (new_left > bottom_bound) new_left = bottom_bound;
            $active_item.css('left', new_left);
            return set_timers();
          }
        });
        if (c === 38 || c === 40 || c === 39 || c === 37) return false;
      }
    });
    $body.keyup(function(e) {
      if (e.keyCode === 17 || e.keyCode === 91 || e.keyCode === 93) {
        ctrl_pressed = false;
      }
      if (e.keyCode === 16) {
        shift_amount = 1;
        return shift_pressed = false;
      }
    });
    $all_colors.each(function() {
      var $t;
      $t = $(this);
      $t.bind('color_update', function(e, options) {
        $t.data({
          hex: options.hex
        });
        return $t.css({
          background: '#' + options.hex
        });
      });
      $t.focus(function() {
        return $t.ColorPickerSetColor($t.val());
      });
      return $t.ColorPicker({
        livePreview: true,
        onChange: function(hsb, hex, rgb) {
          return $t.trigger('color_update', {
            hex: hex,
            timer: true
          });
        },
        onShow: function(colpkr) {
          return $t.blur();
        }
      });
    });
    $font_color.bind('color_update', function(e, options) {
      var $active_items, $t;
      $t = $(this);
      $active_items = $card.find('.active');
      $active_items.each(function() {
        var $active_item, index;
        $active_item = $(this);
        $active_item.css({
          color: '#' + options.hex
        });
        index = $active_item.prevAll().length;
        return active_theme.theme_templates[active_view].lines[index].color = options.hex;
      });
      if (options.timer) return set_timers();
    });
    $qr_color1.bind('color_update', function(e, options) {
      $qr.draw_qr({
        color: options.hex
      });
      if (options.timer) return set_timers();
    });
    $qr_color2.bind('color_update', function(e, options) {
      $qr_bg.css({
        background: '#' + options.hex
      });
      if (options.timer) return set_timers();
    });
    update_family = function() {
      var $active_items, $t;
      $t = $(this);
      $active_items = $card.find('.active');
      $active_items.each(function() {
        var $active_item, index;
        $active_item = $(this);
        $active_item.css({
          'font-family': $t.val()
        });
        index = $active_item.prevAll().length;
        return active_theme.theme_templates[active_view].lines[index].font_family = $t.val();
      });
      return set_timers();
    };
    $font_family.change(update_family);
    update_align = function(align) {
      var $active_items, $t;
      $t = $(this);
      $active_items = $card.find('.active');
      return $active_items.each(function() {
        var $active_item, index;
        $active_item = $(this);
        $active_item.css({
          'text-align': align
        });
        index = $active_item.prevAll().length;
        active_theme.theme_templates[active_view].lines[index].text_align = align;
        return set_timers();
      });
    };
    $fonts.find('.left').click(function() {
      return update_align('left');
    });
    $fonts.find('.center').click(function() {
      return update_align('center');
    });
    $fonts.find('.right').click(function() {
      return update_align('right');
    });
    update_active_size = function(new_h) {
      var $active_items;
      $active_items = $card.find('.active');
      $active_items.each(function() {
        var $active_item;
        $active_item = $(this);
        return $active_item.css({
          'font-size': new_h + 'px',
          'line-height': new_h + 'px',
          'height': new_h + 'px'
        });
      });
      $font_size_indicator.html(new_h);
      return $font_size_slider.slider('value', new_h);
    };
    update_size = function(size_change) {
      var $active_items, $t, h, new_h;
      $t = $(this);
      $active_items = $card.find('.active');
      h = $active_items.height();
      new_h = h + size_change;
      update_active_size(new_h);
      return set_timers();
    };
    $fonts.find('.increase').click(function() {
      return update_size(1);
    });
    $fonts.find('.decrease').click(function() {
      return update_size(-1);
    });
    $font_size_slider.slider({
      min: 1,
      max: 150,
      step: 5,
      slide: function(e, ui) {
        update_active_size(ui.value);
        return set_timers();
      }
    });
    $qr_color2_alpha.slider({
      min: 0,
      max: 100,
      step: 5,
      slide: function(e, ui) {
        $qr_bg.fadeTo(0, ui.value / 100);
        active_theme.theme_templates[active_view].qr.color2_alpha = ui.value / 100;
        return set_timers();
      }
    });
    $qr_radius.change(function() {
      var $t;
      $t = $(this);
      $qr_bg.css({
        'border-radius': $t.val() + 'px'
      });
      active_theme.theme_templates[active_view].qr.radius = $t.val();
      return set_timers();
    });
    change_tab = function(tab_class) {
      var $a, $t;
      $t = $options.find(tab_class);
      $a = $options.find('.active');
      if ($t[0] !== $a[0]) {
        $a.find('ul').stop(true, true).slideUp();
        $a.removeClass('active');
        $t.find('ul').stop(true, true).slideDown();
        return $t.addClass('active');
      }
    };
    $fonts.find('h4').click(function() {
      change_tab('.font_style');
      $lines.first().mousedown();
      $lines.filter(':visible').addClass('active');
      return false;
    });
    $qrs.find('h4').click(function() {
      $qr.mousedown();
      return false;
    });
    unfocus_highlight = function(e) {
      var $t;
      $t = $(e.target);
      if ($t.hasClass('font_style') || $t.closest('.font_style').length || $t.hasClass('qr_style') || $t.closest('.qr_style').length || $t.hasClass('line') || $t.hasClass('qr') || $t.closest('.line').length || $t.closest('.qr').length || $t.closest('.colorpicker').length) {
        return $t = null;
      } else {
        $card.find('.active').removeClass('active');
        $body.unbind('click', unfocus_highlight);
        change_tab('.defaults');
        return false;
      }
    };
    $lines.mousedown(function(e) {
      var $pa, $selected, $t, index, new_h;
      $t = $(this);
      new_h = $t.height();
      $pa = $card.find('.active');
      if (!shift_pressed) $pa.removeClass('active');
      $t.addClass('active');
      $body.bind('click', unfocus_highlight);
      change_tab('.font_style');
      index = $t.prevAll().length;
      $font_family[0].selectedIndex = null;
      $font_color.trigger('color_update', {
        hex: active_theme.theme_templates[active_view].lines[index].color
      });
      $selected = $font_family.find('option[value="' + active_theme.theme_templates[active_view].lines[index].font_family + '"]');
      $selected.focus().attr('selected', 'selected');
      $font_size_indicator.html(new_h);
      return $font_size_slider.slider('value', new_h);
    });
    $qr.mousedown(function() {
      var $pa, $t;
      $t = $(this);
      $pa = $card.find('.active');
      $pa.removeClass('active');
      $t.addClass('active');
      $body.bind('click', unfocus_highlight);
      return change_tab('.qr_style');
    });
    save_timer = 0;
    history_timer = 0;
    set_timers = function() {
      clearTimeout(history_timer);
      return history_timer = setTimeout(function() {
        update_active_theme();
        history.push($.extend(true, {}, active_theme));
        redo_history = [];
        if (!active_theme.not_saved) {
          active_theme.not_saved = true;
          return $save_button.stop(true, true).slideDown();
        }
      }, 200);
    };
    $cat.keyup(set_timers);
    $lines.draggable({
      grid: [10, 10],
      containment: '.designer .card',
      stop: set_timers
    });
    $lines.resizable({
      grid: 10,
      handles: 'e, s, se',
      resize: function(e, ui) {
        var $t, h;
        $t = $(ui.element);
        h = $t.height();
        return update_active_size(h);
      },
      stop: set_timers
    });
    $qr.draggable({
      grid: [10, 10],
      containment: '.designer .card',
      stop: set_timers
    });
    $qr.resizable({
      grid: 10,
      resize: function(e, ui) {
        var $t, h, w;
        $t = $(ui.element);
        h = $t.height();
        w = $t.width();
        $t.find('canvas').css({
          height: h,
          width: w
        });
        return $t.find('.background').css({
          height: h,
          width: w
        });
      },
      containment: '.designer .card',
      handles: 'se',
      aspectRatio: 1,
      stop: set_timers
    });
    $upload.change(function() {
      return $dForm.submit();
    });
    $('.theme_1,.theme_2').click(function() {
      var $c, $t;
      $t = $(this);
      $c = $t.closest('.card');
      $c.click();
      $('.theme_1,.theme_2').removeClass('active');
      $t.addClass('active');
      return false;
    });
    get_position = function($t) {
      var height, left, result, top, width;
      height = parseInt($t.height());
      width = parseInt($t.width());
      left = parseInt($t.css('left'));
      top = parseInt($t.css('top'));
      if (isNaN(height) || isNaN(width) || isNaN(top) || isNaN(left)) return false;
      return result = {
        h: Math.round(height / card_height * 10000) / 100,
        w: Math.round(width / card_width * 10000) / 100,
        x: Math.round(left / card_width * 10000) / 100,
        y: Math.round(top / card_height * 10000) / 100
      };
    };
    update_active_theme = function() {
      var i, line, line_pos, qr_pos, _len3, _ref2, _results;
      qr_pos = get_position($qr);
      active_theme.category = $cat.val();
      active_theme.theme_templates[active_view].color1 = $color1.data('hex');
      active_theme.theme_templates[active_view].color2 = $color2.data('hex');
      active_theme.theme_templates[active_view].qr = {
        x: qr_pos.x,
        y: qr_pos.y,
        h: qr_pos.h,
        w: qr_pos.w,
        color1: $qr_color1.data('hex'),
        color2: $qr_color2.data('hex'),
        color2_alpha: active_theme.theme_templates[active_view].qr.color2_alpha,
        radius: active_theme.theme_templates[active_view].qr.radius
      };
      _ref2 = active_theme.theme_templates[active_view].lines;
      _results = [];
      for (i = 0, _len3 = _ref2.length; i < _len3; i++) {
        line = _ref2[i];
        line_pos = get_position($lines.filter(':eq(' + i + ')'));
        _results.push(active_theme.theme_templates[active_view].lines[i] = {
          x: line_pos.x,
          y: line_pos.y,
          h: line_pos.h,
          w: line_pos.w,
          color: line.color,
          font_family: line.font_family,
          text_align: line.text_align
        });
      }
      return _results;
    };
    execute_save = function(next) {
      var parameters;
      update_active_theme();
      parameters = {
        theme: active_theme,
        do_save: next ? true : false
      };
      return $.ajax({
        url: '/save-theme',
        data: JSON.stringify(parameters),
        success: function(serverResponse) {
          if (!serverResponse.success) {
            $designer.find('.save').show_tooltip({
              message: 'Error saving.'
            });
          }
          if (next) return next(serverResponse);
        },
        error: function() {
          $designer.find('.save').show_tooltip({
            message: 'Error saving.'
          });
          if (next) return next();
        }
      });
    };
    $.s3_result = function(s3_id) {
      if (!no_theme() && s3_id) {
        active_theme.theme_templates[active_view].s3_id = s3_id;
        set_timers();
        return $card.css({
          background: 'url(\'http://cdn.cards.ly/525x300/' + s3_id + '\')'
        });
      } else {
        return $.load_alert({
          content: 'I had trouble saving that image, please try again later.'
        });
      }
    };
    no_theme = function() {
      if (!active_theme) {
        $.load_alert({
          content: 'Please create or select a theme first'
        });
        return true;
      } else {
        return false;
      }
    };
    default_theme = {
      category: '',
      not_saved: true,
      theme_templates: [
        {
          color1: 'FFFFFF',
          color2: '000000',
          s3_id: '',
          qr: {
            color1: '000066',
            color2: 'FFFFFF',
            color2_alpha: .9,
            radius: 10,
            h: 50,
            w: 28.57,
            x: 68.76,
            y: 43.33
          },
          lines: (function() {
            var _results;
            _results = [];
            for (i = 0; i <= 5; i++) {
              _results.push({
                color: '000066',
                font_family: 'Vast Shadow',
                text_align: 'left',
                h: 6.67,
                w: 60,
                x: 3.05,
                y: 5 + i * 10
              });
            }
            return _results;
          })()
        }
      ]
    };
    load_theme = function(theme) {
      var $li, i, line, new_line, pos, theme_template, _k, _len3, _len4, _ref2, _ref3;
      theme_template = theme.theme_templates[active_view];
      /*
          #
          Here is where we create the new theme template if none exists
          #
          - if 1 do bleh
          - if 2 do blah
          #
      */
      if (!theme_template) {
        if (active_view === 2) {
          theme_template = $.extend(true, {}, theme.theme_templates[0]);
          delete theme_template._id;
        }
        if (active_view === 1) {
          theme_template = $.extend(true, {}, theme.theme_templates[0]);
          delete theme_template._id;
          _ref2 = theme_template.lines;
          for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
            line = _ref2[_k];
            $.extend(true, line, {
              h: line.h / 2,
              w: line.w / 2
            });
            new_line = $.extend(true, {}, line);
            new_line.x = 100 - new_line.x - new_line.w;
            theme_template.lines.push(new_line);
          }
          theme_template.qr.h = theme_template.qr.h / 2;
          theme_template.qr.w = theme_template.qr.w / 2;
        }
        theme.theme_templates[active_view] = theme_template;
      }
      if (theme.not_saved) {
        $save_button.stop(true, true).show();
      } else {
        $save_button.stop(true, true).hide();
      }
      active_theme = theme;
      if (theme_template.s3_id) {
        $card.css({
          background: '#FFFFFF url(\'http://cdn.cards.ly/525x300/' + theme_template.s3_id + '\')'
        });
      } else {
        $card.css({
          background: '#FFFFFF'
        });
      }
      if (active_view === 2) {
        $card.css;
        $card.css({
          height: 140,
          width: 252,
          margin: '0 126px',
          padding: 5,
          'background-repeat': 'repeat-y',
          'background-size': '100%'
        });
        update_card_size();
        $card.css({
          height: 290
        });
        $web_fg.show();
        $web_bg.show();
      } else {
        $card.css({
          height: 280,
          width: 505,
          padding: 10,
          margin: 0
        });
        update_card_size();
        $web_fg.hide();
        $web_bg.hide();
      }
      $qr.hide();
      $lines.hide();
      if (active_view === 0 || active_view === 1) {
        $qr.show().css({
          top: theme_template.qr.y / 100 * card_height,
          left: theme_template.qr.x / 100 * card_width,
          height: theme_template.qr.h / 100 * card_height,
          width: theme_template.qr.h / 100 * card_height
        });
        $qr.find('canvas').css({
          height: theme_template.qr.h / 100 * card_height,
          width: theme_template.qr.h / 100 * card_height
        });
        $qr_bg.css({
          'border-radius': theme_template.qr.radius + 'px',
          height: theme_template.qr.h / 100 * card_height,
          width: theme_template.qr.w / 100 * card_width,
          background: '#' + theme_template.qr.color2
        });
        $qr_bg.fadeTo(0, theme_template.qr.color2_alpha);
        $qr.draw_qr({
          color: theme_template.qr.color1
        });
      }
      _ref3 = theme_template.lines;
      for (i = 0, _len4 = _ref3.length; i < _len4; i++) {
        pos = _ref3[i];
        $li = $lines.eq(i);
        $li.show().css({
          top: pos.y / 100 * card_height,
          left: pos.x / 100 * card_width,
          width: (pos.w / 100 * card_width) + 'px',
          height: (pos.h / 100 * card_height) + 'px',
          fontSize: (pos.h / 100 * card_height) + 'px',
          lineHeight: (pos.h / 100 * card_height) + 'px',
          fontFamily: pos.font_family,
          textAlign: pos.text_align,
          color: '#' + pos.color
        });
      }
      $cat.val(theme.category);
      $color1.trigger('color_update', {
        hex: theme_template.color1
      });
      $color2.trigger('color_update', {
        hex: theme_template.color2
      });
      $qr_color1.trigger('color_update', {
        hex: theme_template.qr.color1
      });
      $qr_color2.trigger('color_update', {
        hex: theme_template.qr.color2
      });
      $qr_color2_alpha.slider('value', theme_template.qr.color2_alpha * 100);
      return $qr_radius.find('[value=' + theme_template.qr.radius + ']').attr('selected', 'selected');
    };
    $('.add_new').click(function() {
      var $new_card, temp_theme;
      temp_theme = $.extend(true, {}, default_theme);
      history = [temp_theme];
      $new_card = $('<div class="card" />');
      $new_card.css({
        background: '#FFF'
      });
      $new_card.data('theme', temp_theme);
      $('.categories .category[category=]').append($new_card);
      return $new_card.click();
    });
    $view_buttons = $views.find('div');
    $view_buttons.click(function() {
      var $t, index;
      $t = $(this);
      $view_buttons.removeClass('active');
      $t.addClass('active');
      index = $t.prevAll().length;
      active_view = index;
      return load_theme(active_theme);
    });
    $save_button.click(function() {
      if (no_theme()) return false;
      return $.load_loading({}, function(close_loading) {
        return execute_save(function(result) {
          var $new_card;
          close_loading();
          $new_card = $.create_card_from_theme(active_theme);
          active_theme.not_saved = false;
          active_theme._id = result.theme._id;
          $save_button.stop(true, true).slideUp();
          $new_card.addClass('active');
          $new_card.data('theme', active_theme);
          $('.category .card.active').remove();
          $.add_card_to_category($new_card, active_theme);
          return $new_card.click();
        });
      });
    });
    return $designer.find('.buttons .delete').click(function() {
      if (no_theme()) return false;
      return $.load_modal({
        content: '<p>Are you sure you want to permanently delete this template?</p>',
        height: 160,
        width: 440,
        buttons: [
          {
            label: 'Delete',
            action: function(close_func) {
              active_theme.active = false;
              $.load_loading({}, function(close_loading) {
                return execute_save(function() {
                  close_loading();
                  $('.category .card.active').remove();
                  return $('.category .card:first').click();
                });
              });
              return close_func();
            }
          }, {
            "class": 'gray',
            label: 'Cancel',
            action: function(close_func) {
              return close_func();
            }
          }
        ]
      });
    });
  });
