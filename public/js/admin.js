(function() {
  /*
  
  Theme admin
  
  - All the theme designer stuff
  
  - Plus maybe some similar stuff to home page gallery selection
  
  */  $(function() {
    var $all_colors, $body, $card, $cat, $categories, $color1, $color2, $dForm, $designer, $font_color, $font_family, $fonts, $lines, $options, $qr, $qr_bg, $qr_color1, $qr_color2, $qr_color2_alpha, $qr_radius, $qrs, $upload, active_theme, card_height, card_inner_height, card_inner_width, card_width, change_tab, ctrl_pressed, default_theme, execute_save, fam, font_families, get_position, history, history_timer, i, load_theme, no_theme, redo_history, save_timer, set_timers, shift_amount, shift_pressed, unfocus_highlight, update_active_theme, update_align, update_family, _i, _len;
    $designer = $('.designer');
    $options = $designer.find('.options');
    $card = $designer.find('.card');
    $body = $('body');
    $categories = $('.categories');
    $qr = $card.find('.qr');
    $qr_bg = $qr.find('.background');
    $lines = $card.find('.line');
    $cat = $designer.find('.category_field input');
    $color1 = $designer.find('.color1');
    $color2 = $designer.find('.color2');
    $fonts = $designer.find('.font_style');
    $font_color = $fonts.find('.font_color');
    $font_family = $fonts.find('.font_family');
    $qrs = $designer.find('.qr_style');
    $qr_color1 = $qrs.find('.qr_color1');
    $qr_color2 = $qrs.find('.qr_color2');
    $qr_radius = $qrs.find('.qr_radius');
    $qr_color2_alpha = $qrs.find('.qr_color2_alpha');
    $all_colors = $('.color');
    $dForm = $designer.find('form');
    $upload = $dForm.find('[type=file]');
    card_height = $card.outerHeight();
    card_width = $card.outerWidth();
    card_inner_height = $card.height();
    card_inner_width = $card.width();
    active_theme = false;
    shift_pressed = false;
    ctrl_pressed = false;
    history = [];
    redo_history = [];
    $.ajax({
      url: '/get-themes',
      success: function(all_data) {
        var $category, $li, $my_card, $my_qr, $my_qr_bg, all_themes, i, pos, theme, theme_template, _i, _len, _len2, _ref;
        all_themes = all_data.themes;
        $categories.html('<div class="category" category=""><h4>(no category)</h4></div>');
        for (_i = 0, _len = all_themes.length; _i < _len; _i++) {
          theme = all_themes[_i];
          theme_template = theme.theme_templates[0];
          $my_card = $('<div class="card"><div class="qr"><div class="background" /></div></div>');
          $my_card.data('theme', theme);
          $my_qr = $my_card.find('.qr');
          $my_qr.prep_qr();
          $my_qr_bg = $my_qr.find('.background');
          $my_qr.draw_qr({
            color: theme_template.qr.color1
          });
          $my_qr.find('canvas').css({
            zIndex: 150,
            position: 'absolute',
            height: theme_template.qr.h / 100 * 90,
            width: theme_template.qr.w / 100 * 158
          });
          $my_qr.css({
            position: 'absolute',
            height: theme_template.qr.h / 100 * 90,
            width: theme_template.qr.w / 100 * 158,
            top: theme_template.qr.y / 100 * 90,
            left: theme_template.qr.x / 100 * 158
          });
          $my_qr_bg.css({
            zIndex: 140,
            position: 'absolute',
            'border-radius': theme_template.qr.radius + 'px',
            height: theme_template.qr.h / 100 * 90,
            width: theme_template.qr.w / 100 * 158,
            background: '#' + theme_template.qr.color2
          });
          $my_qr_bg.fadeTo(0, theme_template.qr.color2_alpha);
          _ref = theme_template.lines;
          for (i = 0, _len2 = _ref.length; i < _len2; i++) {
            pos = _ref[i];
            $li = $('<div>gibberish</div>');
            $li.appendTo($my_card).css({
              position: 'absolute',
              top: pos.y / 100 * 90,
              left: pos.x / 100 * 158,
              width: (pos.w / 100 * 158) + 'px',
              fontSize: (pos.h / 100 * 90) + 'px',
              lineHeight: (pos.h / 100 * 90) + 'px',
              fontFamily: pos.font_family,
              textAlign: pos.text_align,
              color: '#' + pos.color
            });
          }
          $my_card.css({
            background: 'url(\'http://cdn.cards.ly/158x90/' + theme_template.s3_id + '\')'
          });
          $category = $categories.find('.category[category=' + theme.category + ']');
          if ($category.length === 0) {
            $category = $('<div class="category" category="' + theme.category + '"><h4>' + theme.category + '</h4></div>');
            $categories.append($category);
          }
          $category.append($my_card);
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
      var $t;
      $t = $(this);
      return load_theme($t.data('theme'));
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
    for (_i = 0, _len = font_families.length; _i < _len; _i++) {
      fam = font_families[_i];
      $font_family.append('<option value="' + fam + '" style="font-family:' + fam + ';">' + fam + '</option>');
    }
    $qr.hide();
    $lines.hide();
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
            if (c === 38) {
              new_top -= shift_amount;
            }
            if (c === 40) {
              new_top += shift_amount;
            }
            top_bound = (card_height - card_inner_height) / 2;
            bottom_bound = top_bound + card_inner_height - $active_item.outerHeight();
            if (new_top < top_bound) {
              new_top = top_bound;
            }
            if (new_top > bottom_bound) {
              new_top = bottom_bound;
            }
            $active_item.css('top', new_top);
          }
          if (c === 37 || c === 39) {
            new_left = parseInt($active_item.css('left'));
            if (c === 37) {
              new_left -= shift_amount;
            }
            if (c === 39) {
              new_left += shift_amount;
            }
            top_bound = (card_width - card_inner_width) / 2;
            bottom_bound = top_bound + card_inner_width - $active_item.outerWidth();
            if (new_left < top_bound) {
              new_left = top_bound;
            }
            if (new_left > bottom_bound) {
              new_left = bottom_bound;
            }
            return $active_item.css('left', new_left);
          }
        });
        if (c === 38 || c === 40 || c === 39 || c === 37) {
          return false;
        }
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
        return active_theme.theme_templates[0].lines[index].color = options.hex;
      });
      if (options.timer) {
        return set_timers();
      }
    });
    $qr_color1.bind('color_update', function(e, options) {
      $qr.draw_qr({
        color: options.hex
      });
      if (options.timer) {
        return set_timers();
      }
    });
    $qr_color2.bind('color_update', function(e, options) {
      $qr_bg.css({
        background: '#' + options.hex
      });
      if (options.timer) {
        return set_timers();
      }
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
        return active_theme.theme_templates[0].lines[index].font_family = $t.val();
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
        return active_theme.theme_templates[0].lines[index].text_align = align;
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
    $qr_color2_alpha.change(function() {
      var $t;
      $t = $(this);
      $qr_bg.fadeTo(0, $t.val());
      active_theme.theme_templates[0].qr.color2_alpha = $t.val();
      return set_timers();
    });
    $qr_radius.change(function() {
      var $t;
      $t = $(this);
      $qr_bg.css({
        'border-radius': $t.val() + 'px'
      });
      active_theme.theme_templates[0].qr.radius = $t.val();
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
      var $pa, $selected, $t, index;
      $t = $(this);
      $pa = $card.find('.active');
      if (!shift_pressed) {
        $pa.removeClass('active');
      }
      $t.addClass('active');
      $body.bind('click', unfocus_highlight);
      change_tab('.font_style');
      index = $t.prevAll().length;
      $font_family[0].selectedIndex = null;
      $font_color.trigger('color_update', {
        hex: active_theme.theme_templates[0].lines[index].color
      });
      $selected = $font_family.find('option[value="' + active_theme.theme_templates[0].lines[index].font_family + '"]');
      return $selected.focus().attr('selected', 'selected');
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
      clearTimeout(save_timer);
      save_timer = setTimeout(function() {
        return execute_save();
      }, 2000);
      clearTimeout(history_timer);
      return history_timer = setTimeout(function() {
        update_active_theme();
        history.push(active_theme);
        return redo_history = [];
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
        return $t.css({
          'font-size': h + 'px',
          'line-height': h + 'px'
        });
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
      if (isNaN(height) || isNaN(width) || isNaN(top) || isNaN(left)) {
        return false;
      }
      return result = {
        h: Math.round(height / card_height * 10000) / 100,
        w: Math.round(width / card_width * 10000) / 100,
        x: Math.round(left / card_width * 10000) / 100,
        y: Math.round(top / card_height * 10000) / 100
      };
    };
    update_active_theme = function() {
      var i, line, line_pos, qr_pos, _len2, _ref, _results;
      qr_pos = get_position($qr);
      active_theme.category = $cat.val();
      active_theme.theme_templates[0].color1 = $color1.data('hex');
      active_theme.theme_templates[0].color2 = $color2.data('hex');
      active_theme.theme_templates[0].qr = {
        x: qr_pos.x,
        y: qr_pos.y,
        h: qr_pos.h,
        w: qr_pos.w,
        color1: $qr_color1.data('hex'),
        color2: $qr_color2.data('hex'),
        color2_alpha: active_theme.theme_templates[0].qr.color2_alpha,
        radius: active_theme.theme_templates[0].qr.radius
      };
      _ref = active_theme.theme_templates[0].lines;
      _results = [];
      for (i = 0, _len2 = _ref.length; i < _len2; i++) {
        line = _ref[i];
        line_pos = get_position($lines.filter(':eq(' + i + ')'));
        _results.push(active_theme.theme_templates[0].lines[i] = {
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
          if (next) {
            return next();
          }
        },
        error: function() {
          $designer.find('.save').show_tooltip({
            message: 'Error saving.'
          });
          if (next) {
            return next();
          }
        }
      });
    };
    $.s3_result = function(s3_id) {
      if (!no_theme() && s3_id) {
        active_theme.theme_templates[0].s3_id = s3_id;
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
      var $li, i, pos, theme_template, _len2, _ref;
      theme_template = theme.theme_templates[0];
      active_theme = theme;
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
      if (theme_template.s3_id) {
        $card.css({
          background: '#FFFFFF url(\'http://cdn.cards.ly/525x300/' + theme_template.s3_id + '\')'
        });
      } else {
        $card.css({
          background: '#FFFFFF'
        });
      }
      _ref = theme_template.lines;
      for (i = 0, _len2 = _ref.length; i < _len2; i++) {
        pos = _ref[i];
        $li = $lines.eq(i);
        $li.show().css({
          top: pos.y / 100 * card_height,
          left: pos.x / 100 * card_width,
          width: (pos.w / 100 * card_width) + 'px',
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
      $qr_color2_alpha.find('[value="' + theme_template.qr.color2_alpha + '"]').attr('selected', 'selected');
      return $qr_radius.find('[value=' + theme_template.qr.radius + ']').attr('selected', 'selected');
    };
    $('.add_new').click(function() {
      var theme;
      theme = default_theme;
      history = [theme];
      return load_theme(theme);
    });
    $designer.find('.buttons .save').click(function() {
      if (no_theme()) {
        return false;
      }
      return $.load_loading({}, function(close_loading) {
        return execute_save(function() {
          return close_loading();
        });
      });
    });
    return $designer.find('.buttons .delete').click(function() {
      if (no_theme()) {
        return false;
      }
      return $.load_modal({
        content: '<p>Are you sure you want to permanently delete this template?</p>',
        height: 160,
        width: 440,
        buttons: [
          {
            label: 'Delete',
            action: function(close_func) {
              /*
                        TODO: Make this delete the template
              
                        So send to the server to delete the template we're on here ...
              
                        */              return close_func();
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
}).call(this);
