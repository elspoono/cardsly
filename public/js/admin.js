
  /*
  
  All the stuff for the admin template designer
  is probably going to be in this section right here.
  
  ok.
  */

  $(function() {
    var $body, $card, $cat, $color1, $color2, $dForm, $designer, $font_color, $font_family, $fonts, $lines, $notfonts, $qr, $upload, active_theme, card_height, card_inner_height, card_inner_width, card_width, default_theme, execute_save, fam, font_families, getPosition, i, loadTheme, noTheme, pageTimer, setPageTimer, shiftAmount, unfocus_highlight, update_family, _i, _len;
    $designer = $('.designer');
    $card = $designer.find('.card');
    $qr = $card.find('.qr');
    $lines = $card.find('.line');
    $body = $(document);
    $cat = $designer.find('.category-field input');
    $color1 = $designer.find('.color1');
    $color2 = $designer.find('.color2');
    $notfonts = $designer.find('.not-font-style');
    $fonts = $designer.find('.font-style');
    $font_color = $fonts.find('.color');
    $font_family = $fonts.find('.font-family');
    $dForm = $designer.find('form');
    $upload = $dForm.find('[type=file]');
    card_height = $card.outerHeight();
    card_width = $card.outerWidth();
    card_inner_height = $card.height();
    card_inner_width = $card.width();
    active_theme = false;
    /*
      GOOGLE FONTS
    
      1. Load them
      2. Make their common names available
    */
    setTimeout(function() {
      return WebFont.load({
        google: {
          families: ["IM+Fell+English+SC::latin", "Julee::latin", "Syncopate::latin", "Gravitas+One::latin", "Quicksand::latin", "Vast+Shadow::latin", "Smokum::latin", "Ovo::latin", "Amatic+SC::latin", "Rancho::latin", "Poly::latin", "Chivo::latin", "Prata::latin", "Abril+Fatface::latin", "Ultra::latin", "Love+Ya+Like+A+Sister::latin", "Carter+One::latin", "Luckiest+Guy::latin", "Gruppo::latin", "Slackey::latin"]
        }
      });
    }, 3000);
    font_families = ['Arial', 'Comic Sans MS', 'Courier New', 'Georgia', 'Impact', 'Times New Roman', 'Trebuchet MS', 'Verdana', 'IM Fell English SC', 'Julee', 'Syncopate', 'Gravitas One', 'Quicksand', 'Vast Shadow', 'Smokum', 'Ovo', 'Amatic SC', 'Rancho', 'Poly', 'Chivo', 'Prata', 'Abril Fatface', 'Ultra', 'Love Ya Like A Sister', 'Carter One', 'Luckiest Guy', 'Gruppo', 'Slackey'].sort();
    /*
      END GOOGLE FONTS
    */
    $font_family.find('option').remove();
    for (_i = 0, _len = font_families.length; _i < _len; _i++) {
      fam = font_families[_i];
      $font_family.append('<option value="' + fam + '" style="font-family:' + fam + ';">' + fam + '</option>');
    }
    $qr.hide();
    $lines.hide();
    /*
      ht = 500
      wd = 500
      console.log wd, ht
      $qr.html '<canvas class="canvas" />'
      elem = $qr.find('.canvas')[0]
      qrc = elem.getContext("2d")
      qrc.canvas.width = wd
      qrc.canvas.height = ht
      d = document
      ecclevel = 1
      qf = genframe('http://cards.ly/fdasfs')
      qrc.lineWidth = 4
      console.log width
      i = undefined
      j = undefined
      px = wd
      px = ht  if ht < wd
      px /= width + 10
      px = Math.round(px - 0.5)
      console.log px
      qrc.clearRect 0, 0, wd, ht
      qrc.fillStyle = "#fff"
      qrc.fillRect 0, 0, px * (width + 8), px * (width + 8)
      qrc.fillStyle = "#000"
      i = 0
      while i < width
        j = 0
        while j < width
          qrc.fillRect px * (i + 4), px * (j + 4), px, px  if qf[j * width + i]
          j++
        i++
    */
    shiftAmount = 1;
    $body.keydown(function(e) {
      var $active_item, bottom_bound, c, new_left, new_top, top_bound;
      $active_item = $card.find('.active');
      c = e.keyCode;
      if ($active_item.length) {
        if (e.keyCode === 16) shiftAmount = 10;
        if (c === 38 || c === 40) {
          new_top = parseInt($active_item.css('top'));
          if (c === 38) new_top -= shiftAmount;
          if (c === 40) new_top += shiftAmount;
          top_bound = (card_height - card_inner_height) / 2;
          bottom_bound = top_bound + card_inner_height - $active_item.outerHeight();
          if (new_top < top_bound) new_top = top_bound;
          if (new_top > bottom_bound) new_top = bottom_bound;
          $active_item.css('top', new_top);
        }
        if (c === 37 || c === 39) {
          new_left = parseInt($active_item.css('left'));
          if (c === 37) new_left -= shiftAmount;
          if (c === 39) new_left += shiftAmount;
          top_bound = (card_width - card_inner_width) / 2;
          bottom_bound = top_bound + card_inner_width - $active_item.outerWidth();
          if (new_left < top_bound) new_left = top_bound;
          if (new_left > bottom_bound) new_left = bottom_bound;
          $active_item.css('left', new_left);
        }
        if (c === 38 || c === 40 || c === 39 || c === 37) return false;
      }
    });
    $body.keyup(function(e) {
      if (e.keyCode === 16) return shiftAmount = 1;
    });
    update_family = function() {
      var $active_item, $t, index;
      console.log(1);
      $t = $(this);
      $active_item = $card.find('.active');
      $active_item.css({
        'font-family': $t.val()
      });
      index = $active_item.prevAll().length;
      return active_theme.positions[index + 1].font_family = $t.val();
    };
    $font_family.change(update_family);
    $font_color.ColorPicker({
      livePreview: true,
      onChange: function(hsb, hex, rgb) {
        $font_color.val(hex);
        return $font_color.keyup();
      }
    });
    $font_color.keyup(function() {
      var $active_item, $t, index;
      $t = $(this);
      $active_item = $card.find('.active');
      $active_item.css({
        color: '#' + $t.val()
      });
      index = $active_item.prevAll().length;
      return active_theme.positions[index + 1].color = $t.val();
    });
    unfocus_highlight = function(e) {
      var $t;
      $t = $(e.target);
      if ($t.hasClass('font-style') || $t.closest('.font-style').length || $t.hasClass('line') || $t.hasClass('qr') || $t.closest('.line').length || $t.closest('.qr').length || $t.closest('.colorpicker').length) {
        return $t = null;
      } else {
        $card.find('.active').removeClass('active');
        $body.unbind('click', unfocus_highlight);
        $fonts.stop(true, false).slideUp();
        $notfonts.stop(true, false).slideDown();
        return false;
      }
    };
    $lines.mousedown(function() {
      var $pa, $t, index;
      $t = $(this);
      $pa = $card.find('.active');
      $pa.removeClass('active');
      $t.addClass('active');
      $body.bind('click', unfocus_highlight);
      index = $t.prevAll().length;
      $fonts.stop(true, false).slideDown();
      $notfonts.stop(true, false).slideUp();
      $font_color.val(active_theme.positions[index + 1].color);
      return $font_family.find('option[value="' + active_theme.positions[index + 1].font_family + '"]').attr('selected', 'selected');
    });
    $qr.mousedown(function() {
      var $pa, $t;
      $t = $(this);
      $pa = $card.find('.active');
      $pa.removeClass('active');
      $t.addClass('active');
      $body.bind('click', unfocus_highlight);
      $fonts.stop(true, false).slideUp();
      return $notfonts.stop(true, false).slideDown();
    });
    pageTimer = 0;
    setPageTimer = function() {
      clearTimeout(pageTimer);
      return pageTimer = setTimeout(function() {
        return execute_save();
      }, 500);
    };
    $cat.keyup(setPageTimer);
    $font_color.keyup(setPageTimer);
    $color1.keyup(setPageTimer);
    $color2.keyup(setPageTimer);
    $lines.draggable({
      grid: [10, 10],
      containment: '.designer .card',
      stop: setPageTimer
    });
    $lines.resizable({
      grid: 10,
      handles: 'n, e, s, w, se',
      resize: function(e, ui) {
        return $(ui.element).css({
          'font-size': ui.size.height + 'px',
          'line-height': ui.size.height + 'px'
        });
      },
      stop: setPageTimer
    });
    $qr.draggable({
      grid: [5, 5],
      containment: '.designer .card',
      stop: setPageTimer
    });
    $qr.resizable({
      grid: 5,
      containment: '.designer .card',
      handles: 'n, e, s, w, ne, nw, se, sw',
      aspectRatio: 1,
      stop: setPageTimer
    });
    $upload.change(function() {
      return $dForm.submit();
    });
    $('.theme-1,.theme-2').click(function() {
      var $c, $t;
      $t = $(this);
      $c = $t.closest('.card');
      $c.click();
      $('.theme-1,.theme-2').removeClass('active');
      $t.addClass('active');
      return false;
    });
    getPosition = function($t) {
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
    execute_save = function(next) {
      var parameters, theme;
      theme = {
        _id: active_theme._id,
        category: $cat.val(),
        positions: [],
        color1: $color1.val(),
        color2: $color2.val(),
        s3_id: active_theme.s3_id
      };
      theme.positions.push(getPosition($qr));
      $lines.each(function() {
        var $t, pos;
        $t = $(this);
        pos = getPosition($t);
        if (pos) return theme.positions.push(pos);
      });
      parameters = {
        theme: theme,
        do_save: next ? true : false
      };
      return $.ajax({
        url: '/saveTheme',
        data: JSON.stringify(parameters),
        success: function(serverResponse) {
          if (!serverResponse.success) {
            $designer.find('.save').showTooltip({
              message: 'Error saving.'
            });
          }
          if (next) return next();
        },
        error: function() {
          $designer.find('.save').showTooltip({
            message: 'Error saving.'
          });
          if (next) return next();
        }
      });
    };
    $.s3_result = function(s3_id) {
      if (!noTheme() && s3_id) {
        active_theme.s3_id = s3_id;
        return $card.css({
          background: 'url(\'http://cdn.cards.ly/525x300/' + s3_id + '\')'
        });
      } else {
        return loadAlert({
          content: 'I had trouble saving that image, please try again later.'
        });
      }
    };
    noTheme = function() {
      if (!active_theme) {
        loadAlert({
          content: 'Please create or select a theme first'
        });
        return true;
      } else {
        return false;
      }
    };
    default_theme = {
      category: '',
      color1: 'FFFFFF',
      color2: '000000',
      s3_id: '',
      positions: [
        {
          h: 45,
          w: 45,
          x: 70,
          y: 40
        }
      ]
    };
    for (i = 0; i <= 5; i++) {
      default_theme.positions.push({
        color: '000000',
        font_family: 'Vast Shadow',
        h: 7,
        w: 50,
        x: 5,
        y: 5 + i * 10
      });
    }
    loadTheme = function(theme) {
      var $li, i, pos, qr, _len2, _ref;
      active_theme = theme;
      qr = theme.positions.shift();
      $qr.show().css({
        top: qr.y / 100 * card_height,
        left: qr.x / 100 * card_width,
        height: qr.h / 100 * card_height,
        width: qr.w / 100 * card_height
      });
      _ref = theme.positions;
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
          color: '#' + pos.color
        });
      }
      theme.positions.unshift(qr);
      $cat.val(theme.category);
      $color1.val(theme.color1);
      return $color2.val(theme.color2);
    };
    $('.add-new').click(function() {
      return loadTheme(default_theme);
      /*
          $new_li = $ '<li class="card" />'
          $('.category[category=""] .gallery').append $new_li
          $new_li.click()
      */
    });
    $designer.find('.buttons .save').click(function() {
      if (noTheme()) return false;
      return loadLoading({}, function(closeLoading) {
        return execute_save(function() {
          return closeLoading();
        });
      });
    });
    return $designer.find('.buttons .delete').click(function() {
      if (noTheme()) return false;
      return loadModal({
        content: '<p>Are you sure you want to permanently delete this template?</p>',
        height: 160,
        width: 440,
        buttons: [
          {
            label: 'Delete',
            action: function(closeFunc) {
              /*
                        TODO: Make this delete the template
              
                        So send to the server to delete the template we're on here ...
              */              return closeFunc();
            }
          }, {
            "class": 'gray',
            label: 'Cancel',
            action: function(closeFunc) {
              return closeFunc();
            }
          }
        ]
      });
    });
  });
