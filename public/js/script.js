(function() {

  /*
  
  This file is everywhere on the site
  
  - We put a lot of library functions in it
  - As well as things that need to happen on every page
  */

  /*
   * 
   * Set settings / defaults
   * 
   * AJAX defaults
   * some constants
   *
  */

  var $window, date_format;

  $.ajaxSetup({
    type: 'POST',
    contentType: 'application/json'
  });

  $window = $(window);

  $.fx.speeds._default = 300;

  $.line_copy = ['Jimbo jo Jiming', 'Banker Extraordinaire', 'Cool Cats Cucumbers', '57 Bakers, Edwarstonville', '555.555.5555', 'New York', 'Apt. #666', 'M thru F - 10 to 7', 'fb.com/my_facebook', '@my_twitter'];

  /*
  */

  $.fn.prep_qr = function(options) {
    var settings;
    settings = {
      url: 'http://cards.ly'
    };
    return this.each(function(i) {
      var $canvas, $t, count, qrcode, scale, size;
      if (options) $.extend(settings, options);
      $t = $(this);
      $canvas = $('<canvas />');
      $t.append($canvas);
      qrcode = new QRCode(-1, QRErrorCorrectLevel.H);
      qrcode.addData(settings.url);
      qrcode.make();
      $t.data('qrcode', qrcode);
      count = qrcode.getModuleCount();
      scale = 3;
      size = count * scale + scale * 4;
      $t.css({
        height: size,
        width: size
      });
      return $canvas.attr({
        height: size,
        width: size
      });
    });
  };

  $.fn.draw_qr = function(options) {
    var settings;
    settings = {
      color: '000000'
    };
    return this.each(function(i) {
      var $t, c, canvas, count, ctx, cutHex, hexToB, hexToG, hexToR, qrcode, r, scale, size, _ref, _results;
      if (options) $.extend(settings, options);
      $t = $(this);
      qrcode = $t.data('qrcode');
      count = qrcode.getModuleCount();
      scale = 3;
      size = count * scale + scale * 4;
      canvas = $t.find('canvas')[0];
      if (canvas && canvas.getContext) {
        ctx = canvas.getContext("2d");
        hexToR = function(h) {
          return parseInt((cutHex(h)).substring(0, 2), 16);
        };
        hexToG = function(h) {
          return parseInt((cutHex(h)).substring(2, 4), 16);
        };
        hexToB = function(h) {
          return parseInt((cutHex(h)).substring(4, 6), 16);
        };
        cutHex = function(h) {
          if (h.charAt(0) === "#") {
            return h.substring(1, 7);
          } else {
            return h;
          }
        };
        ctx.fillStyle = 'rgb(' + hexToR(settings.color) + ',' + hexToG(settings.color) + ',' + hexToB(settings.color) + ')';
        _results = [];
        for (r = 0, _ref = count - 1; 0 <= _ref ? r <= _ref : r >= _ref; 0 <= _ref ? r++ : r--) {
          _results.push((function() {
            var _ref2, _results2;
            _results2 = [];
            for (c = 0, _ref2 = count - 1; 0 <= _ref2 ? c <= _ref2 : c >= _ref2; 0 <= _ref2 ? c++ : c--) {
              if (qrcode.isDark(c, r)) {
                _results2.push(ctx.fillRect(r * scale + scale * 2, c * scale + scale * 2, scale, scale));
              } else {
                _results2.push(void 0);
              }
            }
            return _results2;
          })());
        }
        return _results;
      }
    });
  };

  $.fn.qr = function(options) {
    var settings;
    settings = {
      color: '000000',
      url: 'http://cards.ly',
      height: 50,
      width: 50
    };
    return this.each(function(i) {
      var $t;
      if (options) $.extend(settings, options);
      $t = $(this);
      $t.prep_qr({
        url: settings.url
      });
      $t.draw_qr({
        color: settings.color
      });
      $t.css({
        height: settings.height,
        width: settings.width
      });
      $t.find('canvas').css({
        height: settings.height,
        width: settings.width
      });
      if (typeof G_vmlCanvasManager !== 'undefined') {
        $t.find('canvas')[0].width = settings.width;
        $t.find('canvas')[0].height = settings.height;
        return G_vmlCanvasManager.initElement($t.find('canvas')[0]);
      }
    });
  };

  /*
    * 
    *
    * Card Thumbnail Drawing Functions
    *
    *
  */

  $.create_card_from_theme = function(theme, size) {
    var $li, $my_card, $my_qr, $my_qr_bg, i, pos, theme_template, _len, _ref;
    if (!size) {
      size = {
        height: 90,
        width: 158
      };
    }
    theme_template = theme.theme_templates[0];
    $my_card = $('<div class="card"><div class="qr"><div class="background" /></div></div>');
    $my_card.data('theme', theme);
    $my_qr = $my_card.find('.qr');
    $my_qr_bg = $my_qr.find('.background');
    $my_qr.qr({
      color: theme_template.qr.color1,
      height: theme_template.qr.h / 100 * size.height,
      width: theme_template.qr.w / 100 * size.width
    });
    $my_qr.find('canvas').css({
      zIndex: 150,
      position: 'absolute'
    });
    $my_qr.css({
      position: 'absolute',
      top: theme_template.qr.y / 100 * size.height,
      left: theme_template.qr.x / 100 * size.width
    });
    $my_qr_bg.css({
      zIndex: 140,
      position: 'absolute',
      'border-radius': theme_template.qr.radius + 'px',
      height: theme_template.qr.h / 100 * size.height,
      width: theme_template.qr.w / 100 * size.width,
      background: '#' + theme_template.qr.color2
    });
    $my_qr_bg.fadeTo(0, theme_template.qr.color2_alpha);
    _ref = theme_template.lines;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      pos = _ref[i];
      $li = $('<div class="line">' + $.line_copy[i] + '</div>');
      $li.appendTo($my_card).css({
        position: 'absolute',
        top: pos.y / 100 * size.height,
        left: pos.x / 100 * size.width,
        width: (pos.w / 100 * size.width) + 'px',
        fontSize: (pos.h / 100 * size.height) + 'px',
        lineHeight: (pos.h / 100 * size.height) + 'px',
        fontFamily: pos.font_family,
        textAlign: pos.text_align,
        color: '#' + pos.color
      });
    }
    return $my_card.css({
      background: 'url(\'http://cdn.cards.ly/' + size.width + 'x' + size.height + '/' + theme_template.s3_id + '\')'
    });
  };

  $.add_card_to_category = function($my_card, theme) {
    var $categories, $category;
    $categories = $('.categories');
    $category = $categories.find('.category[category="' + theme.category + '"]');
    if ($category.length === 0) {
      $category = $('<div class="category" category="' + theme.category + '"><h4>' + (theme.category || '(no category)') + '<div class="arrow_container"><div class="arrow"></div></div></h4><div class="cards"></div></div>');
      $categories.prepend($category);
    }
    return $category.find('.cards').prepend($my_card);
  };

  /*
   * 
   * 
   * Generic Tooltip function
   * 
   * - does a little tooltip dealy bob on any element
   *
   * - usually used for form inputs
   *
  */

  $.fn.show_tooltip = function(options) {
    var settings;
    settings = {
      position: 'below'
    };
    return this.each(function(i) {
      var $t, data, offset, toRemove, tooltip, _i, _len;
      if (options) $.extend(settings, options);
      $t = $(this);
      offset = $t.offset();
      data = $t.data('tooltips');
      if (!data) data = [];
      if (settings.message) {
        tooltip = $('<div class="tooltip" />');
        tooltip.html(settings.message);
        tooltip.css({
          left: offset.left,
          top: offset.top + (settings.position === 'below' ? $t.height() + 40 : 0)
        });
        $('body').append(tooltip);
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          i = data[_i];
          i.stop(true, true).fadeOut();
        }
        data.push(tooltip);
        if (data.length > 5) {
          toRemove = data.shift();
          toRemove.remove();
        }
        $t.data('tooltips', data);
      } else {
        tooltip = data[data.length_1];
      }
      /*
      
              TODO : Make the animation in a custom slide up / slide down thing with $.animate
      */
      tooltip.stop(true, true).fadeIn().delay(4000).fadeOut();
      return $t.data('tooltip', tooltip);
    });
  };

  /*
     * 
     * Modal Handling Functions
     * 
     * Basic load
     * 
     *
  */

  $.load_modal = function(options, next) {
    var $body, buttons, close, height, i, modal, my_next, resize_event, scrollbar_width, settings, width, win, _fn, _i, _len, _ref;
    scrollbar_width = $.scrollbar_width();
    modal = $('<div class="modal" />');
    win = $('<div class="window" />');
    close = $('<div class="close" />');
    $body = $(document);
    settings = {
      width: 500,
      height: 235,
      closeText: 'close'
    };
    if (options) $.extend(settings, options);
    $('iframe').css('visibility', 'hidden');
    my_next = function() {
      $window.unbind('scroll resize', resize_event);
      $window.unbind('resize', resize_event);
      $body.css({
        overflow: 'inherit',
        'padding-right': 0
      });
      modal.fadeOut(function() {
        return modal.remove();
      });
      close.fadeOut(function() {
        return close.remove();
      });
      return win.fadeOut(function() {
        win.remove();
        $('iframe').css('visibility', '');
        if ($('.window').length === 0) return $('#container').show();
      });
    };
    if (settings.closeText) close.html(settings.closeText);
    if (settings.content) win.html(settings.content);
    if (settings.height) {
      win.css({
        'min-height': settings.height
      });
    }
    if (settings.width) win.width(settings.width);
    buttons = $('<div class="buttons" />');
    /*
      Loop through the buttons passed in.
    
      Buttons will be passed in as an array of objects. Each object with label string and action function
    
      settings.buttons = [
        {
          label: 'Button 1'
          action: function(){ alert('Button 1 clicked')}
        },
        {
          label: 'Button 2'
          action: function(){ alert('Button 2 clicked')}
        }
      ]
    */
    if (settings.buttons) {
      _ref = settings.buttons;
      _fn = function(i) {
        var this_button;
        this_button = $('<input type="button" class="button" value="' + i.label + '" class="submit">');
        if (i["class"]) {
          this_button.addClass(i["class"]);
        } else {
          this_button.addClass('normal');
        }
        this_button.click(function() {
          return i.action(my_next);
        });
        return buttons.append(this_button);
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _fn(i);
      }
    }
    win.append(buttons);
    $('body').append(modal, close, win);
    resize_event = function() {
      var height, top, width;
      width = $window.width();
      height = $window.height();
      if (width < settings.width || height < win.height()) {
        $window.unbind('scroll resize', resize_event);
        close.css({
          position: 'relative'
        });
        win.width(width - 60).css({
          position: 'relative'
        });
        $('#container').hide();
        top = close.offset().top;
        modal.css({
          top: 0,
          left: 0,
          width: width,
          height: top
        });
        return window.scroll(0, top);
      } else {
        $body.css({
          overflow: 'hidden',
          'padding-right': scrollbar_width
        });
        win.position({
          of: $window,
          at: 'center center',
          my: 'center center',
          offset: '0 40px'
        });
        modal.position({
          of: $window,
          at: 'center center'
        });
        return close.position({
          of: win,
          at: 'right top',
          my: 'right bottom',
          offset: '0 0'
        });
      }
    };
    $window.bind('resize scroll', resize_event);
    modal.click(my_next);
    close.click(my_next);
    width = $window.width();
    height = $window.height();
    if (width < settings.width || height < win.height()) {
      modal.show();
      win.show();
      close.show();
    } else {
      modal.fadeIn();
      win.fadeIn();
      close.fadeIn();
    }
    if (next) next(my_next);
    return resize_event();
  };

  /*
   * 
   * Modal Handling Functions
   * 
   * Load Loading (Subclass of $.load_modal)
   * 
   *
  */

  $.load_loading = function(options, next) {
    var i, modified_options, v;
    options = options || {};
    modified_options = {
      content: 'Loading ... ',
      height: 100,
      width: 200
    };
    for (i in options) {
      v = options[i];
      modified_options[i] = options[i];
    }
    return $.load_modal(modified_options, next);
  };

  /*
   * 
   * Modal Handling Functions
   * 
   * Load Confirm (Subclass of $.load_modal)
   * like javascript confirm()
   *
  */

  $.load_confirm = function(options, next) {
    var i, modified_options, v;
    options = options || {};
    modified_options = {
      content: 'Confirm',
      height: 80,
      width: 300
    };
    for (i in options) {
      v = options[i];
      modified_options[i] = options[i];
    }
    return $.load_modal(modified_options, next);
  };

  /*
   * 
   * Modal Handling Functions
   * 
   * Load Alert (Subclass of $.load_modal)
   * like javascript alert()
   *
  */

  $.load_alert = function(options, next) {
    var i, modified_options, v;
    options = options || {};
    next = next || function() {};
    if (typeof options === 'string') {
      options = {
        content: options
      };
    }
    modified_options = {
      content: 'Alert',
      buttons: [
        {
          action: function(close) {
            return close();
          },
          label: 'Ok'
        }
      ],
      height: 80,
      width: 300
    };
    for (i in options) {
      v = options[i];
      modified_options[i] = options[i];
    }
    return $.load_modal(modified_options, next);
  };

  /*
   * jQuery Scrollbar Width v1.0
   * 
   * Copyright 2011, Rasmus Schultz
   * Licensed under LGPL v3.0
   * http:#www.gnu.org/licenses/lgpl-3.0.txt
  */

  $.scrollbar_width = function() {
    var $body, w;
    if (!$._scrollbar_width) {
      $body = $('body');
      w = $body.css('overflow', 'hidden').width();
      $body.css('overflow', 'scroll');
      w -= $body.width();
      if (!w) w = $body.width() - $body[0].clientWidth;
      $body.css('overflow', '');
      $._scrollbar_width = w;
    }
    return $._scrollbar_width;
  };

  /*
  #http:#stevenlevithan.com/assets/misc/date.format.js
   * Date Format 1.2.3
   * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
   * MIT license
   *
   * Includes enhancements by Scott Trenda <scott.trenda.net>
   * and Kris Kowal <cixar.com/~kris.kowal/>
   *
   * Accepts a date, a mask, or a date and a mask.
   * Returns a formatted version of the given date.
   * The date defaults to the current date/time.
   * The mask defaults to date_format.masks.default.
  */

  date_format = (function() {
    var pad, timezone, timezoneClip, token;

    function date_format() {}

    token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g;

    timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g;

    timezoneClip = /[^-+\dA-Z]/g;

    pad = function(val, len) {
      val = String(val);
      len = len || 2;
      while (val.length < len) {
        val = "0" + val;
      }
      return val;
    };

    date_format.prototype.format = function(date, mask, utc) {
      var D, H, L, M, d, dF, flags, m, o, s, y, _;
      dF = date_format.prototype;
      if (arguments.length === 1 && Object.prototype.toString.call(date) === "[object String]" && !/\d/.test(date)) {
        mask = date;
        date = void 0;
      }
      date = date ? new Date(date) : new Date;
      if (isNaN(date)) throw SyntaxError("invalid date");
      mask = String(dF.masks[mask] || mask || dF.masks["default"]);
      if (mask.slice(0, 4) === "UTC:") {
        mask = mask.slice(4);
        utc = true;
      }
      _ = utc ? "getUTC" : "get";
      d = date[_ + "Date"]();
      D = date[_ + "Day"]();
      m = date[_ + "Month"]();
      y = date[_ + "FullYear"]();
      H = date[_ + "Hours"]();
      M = date[_ + "Minutes"]();
      s = date[_ + "Seconds"]();
      L = date[_ + "Milliseconds"]();
      o = utc != null ? utc : {
        0: date.getTimezoneOffset()
      };
      flags = {
        d: d,
        dd: pad(d),
        ddd: dF.i18n.dayNames[D],
        dddd: dF.i18n.dayNames[D + 7],
        m: m + 1,
        mm: pad(m + 1),
        mmm: dF.i18n.monthNames[m],
        mmmm: dF.i18n.monthNames[m + 12],
        yy: String(y).slice(2),
        yyyy: y,
        h: H % 12 || 12,
        hh: pad(H % 12 || 12),
        H: H,
        HH: pad(H),
        M: M,
        MM: pad(M),
        s: s,
        ss: pad(s),
        l: pad(L, 3),
        L: pad(L > 99 ? Math.round(L / 10) : L),
        t: H < 12 ? "a" : "p",
        tt: H < 12 ? "am" : "pm",
        T: H < 12 ? "A" : "P",
        TT: H < 12 ? "AM" : "PM",
        Z: utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
        o: (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
        S: ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 !== 10) * d % 10]
      };
      return mask.replace(token, function($0) {
        if (flags) {
          return flags[$0];
        } else {
          return $0.slice(1, $0.length - 1);
        }
      });
    };

    date_format.prototype.masks = {
      "default": "ddd mmm dd yyyy HH:MM:ss",
      shortDate: "m/d/yy",
      mediumDate: "mmm d, yyyy",
      longDate: "mmmm d, yyyy",
      fullDate: "dddd, mmmm d, yyyy",
      shortTime: "h:MM TT",
      mediumTime: "h:MM:ss TT",
      longTime: "h:MM:ss TT Z",
      isoDate: "yyyy-mm-dd",
      isoTime: "HH:MM:ss",
      isoDateTime: "yyyy-mm-dd'T'HH:MM:ss",
      isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
    };

    date_format.prototype.i18n = {
      dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    };

    return date_format;

  })();

  Date.prototype.format = function(mask, utc) {
    var a;
    a = new date_format;
    return a.format(this, mask, utc);
  };

  /*
   * jQuery Cookie plugin
   *
   * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
   * Dual licensed under the MIT and GPL licenses:
   * http://www.opensource.org/licenses/mit-license.php
   * http://www.gnu.org/licenses/gpl.html
   *
  */

  jQuery.cookie = function(key, value, options) {
    var days, decode, regex, result, t;
    if (arguments.length > 1 && String(value) !== "[object Object]") {
      options = jQuery.extend({}, options);
      if (value === null || value === void 0) options.expires = -1;
      if (typeof options.expires === 'number') {
        days = options.expires;
        t = options.expires = new Date();
        t.setDate(t.getDate() + days);
      }
      value = String(value);
      document.cookie = [encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value), options.expires ? '; expires=' + options.expires.toUTCString() : '', options.path ? '; path=' + options.path : '; path=/', options.domain ? '; domain=' + options.domain : '', options.secure ? '; secure' : ''].join('');
    }
    options = value || {};
    decode = options.raw ? function(s) {
      return s;
    } : decodeURIComponent;
    regex = '(?:^|; )' + encodeURIComponent(key) + '=([^;]*)';
    if ((result = new RegExp(regex).exec(document.cookie))) {
      return decode(result[1]);
    } else {
      return null;
    }
  };

  $.fn.box_rotate = function(options) {
    var settings;
    settings = {
      position: 'below'
    };
    return this.each(function(i) {
      var $t, degrees, rotate;
      if (options) $.extend(settings, options);
      $t = $(this);
      degrees = settings.degrees;
      rotate = Math.floor((degrees / 360) * 100) / 100;
      return $t.css({
        '-moz-transform': 'rotate(' + degrees + 'deg)',
        '-webkit-transform': 'rotate(' + degrees + 'deg)',
        '-o-transform': 'rotate(' + degrees + 'deg)',
        '-ms-transform': 'rotate(' + degrees + 'deg)',
        'filter:progid': 'DXImageTransform.Microsoft.BasicImage(rotation=' + rotate + ')'
      });
    });
  };

  /*
  The 
  $ ->
  
    Means everything under him (like me, indented here)
    WILL be done on document ready event.
  */

  $(function() {
    var $a, $address, $address_result, $am, $body, $card, $categories, $city, $designer, $email_text, $error, $existing_payment, $feedback_a, $gs, $lines, $mc, $qr, $qr_bg, $quantity, $shipping_method, $view_buttons, $win, active_theme, active_view, address_timer, card_height, card_inner_height, card_inner_width, card_width, close_menu, expand_menu, input_timer, item_name, load_theme, monitor_for_complete, path, set_address_timer, set_timers, shift_pressed, successful_login, update_card_size, update_cards;
    if (document.location.href.match(/#bypass_splash/i)) {
      $.cookie('bypass_splash', true);
    }
    if ($.browser.msie && parseInt($.browser.version, 10) < 8 && !document.location.href.match(/splash/) && !$.cookie('bypass_splash')) {
      document.location.href = '/splash';
    }
    $error = $('.error');
    if ($error.length) {
      $('html,body').animate({
        scrollTop: $error.offset().top - 50
      }, 500, function() {
        return $error.stop(true, true).delay(300).fadeOut().fadeIn().fadeOut().fadeIn().fadeOut().fadeIn();
      });
    }
    /*
      Profile MENU in the TOP RIGHT
      Thing that shows a drop down
    */
    $a = $('.account_link');
    $am = $a.find('.account_menu');
    $body = $(document);
    $('.small_nav li').live('mouseenter', function() {
      return $(this).addClass('hover');
    });
    $('.small_nav li').live('mouseleave', function() {
      return $(this).removeClass('hover');
    });
    close_menu = function(e) {
      var $t;
      $t = $(e.target);
      if ($t.closest('.account_link').length) {
        $a = $t.closest('li').find('a');
        document.location.href = $a.attr('href');
      } else {
        $a.removeClass('click');
        $am.slideUp(150);
        $a.one('click', expand_menu);
        $body.unbind('click', close_menu);
      }
      return false;
    };
    expand_menu = function() {
      $am.slideDown(150);
      $a.addClass('click');
      $body.bind('click', close_menu);
      return false;
    };
    $a.one('click', expand_menu);
    path = document.location.href.replace(/http:\/\/[^\/]*/ig, '');
    $('.design_button').click(function() {
      if (path !== '/' && path !== '/home') {
        document.location.href = '/#design-button';
      } else {
        $('html,body').animate({
          scrollTop: $('.section:eq(1)').offset().top
        }, 500, function() {
          return $('.home_designer .line:first').click();
        });
      }
      return false;
    });
    if (path === '/#design-button') {
      document.location.href = '#';
      $('.design_button').click();
    }
    successful_login = function() {
      if (path === '/login') {
        return document.location.href = '/admin';
      } else {
        return $.load_loading({}, function(loading_close) {
          return $.ajax({
            url: '/get-user',
            success: function(user) {
              var $existing_payment, $s;
              loading_close();
              if (user.err) {
                return $.load_alert({
                  content: user.err
                });
              } else {
                $s = $('.signins');
                $s.html('<p>Congratulations ' + (user.name || user.email) + ', you are now connected to cards.ly</p><div class="check"><input type="checkbox" name="do_send" id="do_send" checked="checked" class="do_send"><label for="do_send">Send my order confirmation email to:</label></div><div class="input"><input name="email_to_send" placeholder="my@email.com" class="email_to_send" value="' + (user.email || '') + '"></div>');
                $('.small_nav .login').replaceWith('<li class="account_link"><a href="/settings">' + (user.name || user.email) + '<div class="gear"><img src="/images/buttons/gear.png"></div></a><ul class="account_menu"><li><a href="/settings">Settings</a></li><li><a href="/logout">Logout</a></li></ul></li>');
                if (user.payyment_method && user.payment_method.last_four_digits) {
                  $existing_payment = $('<div class="existing_payment"><div class="type"></div><div class="expiry">' + user.existing_payment.expiry_month + '/\
' + user.existing_payment.expiry_year + '</div><div class="last_4">**** - **** - **** - \
' + user.existing_payment.last_four_digits + '</div><div class="small button gray">Use New Card</div></div>');
                  $existing_payment.find('.button').click(function() {
                    $existing_payment.remove();
                    $('.order_total form').show();
                    return false;
                  });
                  return $('.order_total form').hide();
                }
              }
            },
            error: function(err) {
              loading_close();
              return $.load_alert({
                content: 'Our apologies. A server error occurred.'
              });
            }
          });
        });
      }
    };
    monitor_for_complete = function(opened_window) {
      var checkTimer;
      $.cookie('success_login', null);
      return checkTimer = setInterval(function() {
        if ($.cookie('success_login')) {
          successful_login();
          $.cookie('success_login', null);
          window.focus();
          return opened_window.close();
        }
      }, 200);
    };
    $('.google').click(function() {
      monitor_for_complete(window.open('auth/google', 'auth', 'height=350,width=600'));
      return false;
    });
    $('.twitter').click(function() {
      monitor_for_complete(window.open('auth/twitter', 'auth', 'height=400,width=500'));
      return false;
    });
    $('.facebook').click(function() {
      monitor_for_complete(window.open('auth/facebook', 'auth', 'height=400,width=900'));
      return false;
    });
    $('.linkedin').click(function() {
      monitor_for_complete(window.open('auth/linkedin', 'auth', 'height=300,width=400'));
      return false;
    });
    $('.login_form').submit(function() {
      $.load_loading({}, function(loading_close) {
        return $.ajax({
          url: '/login',
          data: JSON.stringify({
            email: $('.email_login').val(),
            password: $('.password_login').val()
          }),
          success: function(data) {
            loading_close();
            if (data.err) {
              return $.load_alert({
                content: data.err
              });
            } else {
              return successful_login();
            }
          },
          error: function(err) {
            loading_close();
            return $.load_alert({
              content: 'Our apologies. A server error occurred.'
            });
          }
        });
      });
      return false;
    });
    $('.new').click(function() {
      $.load_modal({
        content: '<div class="create_form"><p>Email Address:<br><input class="email"></p><p>Password:<br><input type="password" class="password"></p></p><p>Repeat Password:<br><input type="password" class="password2"></p></div>',
        buttons: [
          {
            label: 'Create New',
            action: function(form_close) {
              var email, err, password, password2;
              email = $('.email');
              password = $('.password');
              password2 = $('.password2');
              err = false;
              if (email.val() === '' || password.val() === '' || password2.val() === '') {
                err = 'Please enter an email once and the password twice.';
              } else if (password.val() !== password2.val()) {
                err = 'I\'m sorry, I don\'t think those passwords match.';
              } else if (password.val().length < 4) {
                err = 'Password should be a little longer, at least 4 characters.';
              }
              if (err) {
                return $.load_alert({
                  content: err
                });
              } else {
                form_close();
                return $.load_loading({}, function(loading_close) {
                  return $.ajax({
                    url: '/create-user',
                    data: JSON.stringify({
                      email: email.val(),
                      password: password.val()
                    }),
                    success: function(data) {
                      loading_close();
                      if (data.err) {
                        return $.load_alert({
                          content: data.err
                        });
                      } else {
                        return successful_login();
                      }
                    },
                    error: function(err) {
                      loading_close();
                      return $.load_alert({
                        content: 'Our apologies. A server error occurred.'
                      });
                    }
                  });
                });
              }
            }
          }
        ],
        height: 340,
        width: 400
      });
      $('.email').data('timer', 0).keyup(function() {
        var $t;
        $t = $(this);
        clearTimeout($t.data('timer'));
        return $t.data('timer', setTimeout(function() {
          if ($t.val().match(/.{1,}@.{1,}\..{1,}/)) {
            $t.removeClass('error').addClass('valid');
            return $.ajax({
              url: '/check-email',
              data: JSON.stringify({
                email: $t.val()
              }),
              success: function(full_responsE) {
                if (full_responsE.count === 0) {
                  $t.removeClass('error').addClass('valid');
                  return $t.show_tooltip({
                    message: full_responsE.email + ' is good'
                  });
                } else {
                  $t.removeClass('valid').addClass('error');
                  return $t.show_tooltip({
                    message: '' + full_responsE.email + ' is in use. Try signing in with a social login.'
                  });
                }
              }
            });
          } else {
            return $t.removeClass('valid').addClass('error').show_tooltip({
              message: 'Is that an email?'
            });
          }
        }, 1000));
      });
      $('.password').data('timer', 0).keyup(function() {
        var $t;
        $t = $(this);
        clearTimeout($t.data('timer'));
        return $t.data('timer', setTimeout(function() {
          if ($t.val().length >= 4) {
            return $t.removeClass('error').addClass('valid');
          } else {
            return $t.removeClass('valid').addClass('error').show_tooltip({
              message: 'Just ' + (6 - $t.val().length) + ' more characters please.'
            });
          }
        }, 1000));
      });
      $('.password2').data('timer', 0).keyup(function() {
        var $t;
        $t = $(this);
        clearTimeout($t.data('timer'));
        return $t.data('timer', setTimeout(function() {
          if ($t.val() === $('.password').val()) {
            $t.removeClass('error').addClass('valid');
            return $('.step_4').fadeTo(300, 1);
          } else {
            return $t.removeClass('valid').addClass('error').show_tooltip({
              message: 'Passwords should match please.'
            });
          }
        }, 1000));
      });
      return false;
    });
    $feedback_a = $('.feedback a');
    $feedback_a.mouseover(function() {
      var $feedback;
      $feedback = $('.feedback');
      if ($.browser.msie && parseInt($.browser.version, 10) < 9) {
        return console.log('Do something for IE7 here');
      } else {
        return $feedback.stop(true, false).animate({
          right: '-37px'
        }, 250);
      }
    });
    $feedback_a.mouseout(function() {
      var $feedback;
      $feedback = $('.feedback');
      if ($.browser.msie && parseInt($.browser.version, 10) < 9) {
        return console.log('Do something for IE7 here');
      } else {
        return $feedback.stop(true, false).animate({
          right: '-45px'
        }, 250);
      }
    });
    $email_text = $('.hidden_email');
    console.log($email_text.text());
    $feedback_a.click(function(e) {
      e.preventDefault();
      $.load_modal({
        content: '<div class="feedback_form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback_text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email"cols="40" value="' + ($email_text.text()) + '"></p></div>',
        width: 400,
        height: 300,
        buttons: [
          {
            label: 'Send Feedback',
            action: function(form_close) {
              form_close();
              return $.load_loading({}, function(loading_close) {
                return $.ajax({
                  url: '/send-feedback',
                  data: JSON.stringify({
                    content: $('.feedback_text').val(),
                    email: $('.emailNotUser').val()
                  }),
                  success: function(data) {
                    loading_close();
                    if (data.err) {
                      return $.load_alert({
                        content: data.err
                      });
                    } else {
                      return successfulFeedback()(function() {
                        $s.html('Feedback Sent');
                        return $s.fadeIn(100000);
                      });
                    }
                  },
                  error: function(err) {
                    loading_close();
                    return $.load_alert({
                      content: 'Our apologies. A server error occurred, feedback could not be sent.'
                    });
                  }
                }, 1000);
              });
            }
          }
        ]
      });
      return false;
    });
    $gs = $('.gallery_select');
    $gs.css({
      left: -220,
      top: 0
    });
    $('.category .card').live('click', function() {
      var $t;
      $t = $(this);
      $('.card').removeClass('active');
      $t.addClass('active');
      if ($gs.offset().top === $t.offset().top - 10) {
        return $gs.animate({
          left: $t.offset().left - 10
        }, 500);
      } else {
        return $gs.stop(true, false).animate({
          top: $t.offset().top - 10
        }, 500, 'linear', function() {
          return $gs.animate({
            left: $t.offset().left - 10
          }, 500, 'linear');
        });
      }
    });
    $('.category h4').live('click', function() {
      var $c, $g, $t;
      $t = $(this);
      $c = $t.closest('.category');
      $g = $c.find('.cards');
      $a = $('.category.active');
      if (!$c.hasClass('active')) {
        $a.removeClass('active');
        $a.find('.cards').show().slideUp(400);
        $gs.hide();
        $c.find('.cards').slideDown(400, function() {
          $gs.show();
          return $c.find('.card:first').click();
        });
        return $c.addClass('active');
      }
    });
    $('.button').live('mouseenter', function() {
      return $(this).addClass('hover');
    }).live('mouseleave', function() {
      return $(this).removeClass('hover');
    }).live('mousedown', function() {
      return $(this).addClass('click');
    }).live('mouseup', function() {
      return $(this).removeClass('click');
    });
    $designer = $('.home_designer');
    $categories = $('.categories');
    $card = $designer.find('.card');
    $qr = $card.find('.qr');
    $qr_bg = $qr.find('.background');
    $lines = $card.find('.line');
    $view_buttons = $('.views .option');
    $quantity = $('.quantity');
    $shipping_method = $('.shipping_method');
    $address = $('.address');
    $address_result = $('.address_result');
    $city = $('.city');
    $body = $(document);
    active_theme = false;
    active_view = 0;
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
    $qr.prep_qr();
    $.ajax({
      url: '/get-themes',
      success: function(all_data) {
        var $active_theme, $active_view, $my_card, active_theme_id, all_themes, theme, _i, _len;
        all_themes = all_data.themes;
        $categories.html('');
        active_theme_id = $('.active_theme_id').html();
        $active_theme = false;
        for (_i = 0, _len = all_themes.length; _i < _len; _i++) {
          theme = all_themes[_i];
          $my_card = $.create_card_from_theme(theme);
          if (active_theme_id && theme._id === active_theme_id) {
            $active_theme = $my_card;
          }
          $.add_card_to_category($my_card, theme);
        }
        if ($active_theme) {
          $active_theme.closest('.category').addClass('active');
          $active_theme.click();
        } else {
          $categories.find('.category:first h4').click();
        }
        $active_view = $('.active_view');
        if ($active_view.html()) {
          $view_buttons.filter(':eq(' + $active_view.html() + ')').click();
        }
        return $lines.each(function(i) {
          return update_cards(i, $(this).html());
        });
      },
      error: function() {
        return $.load_alert({
          content: 'Error loading themes. Please try again later.'
        });
      }
    });
    $('.category .card').live('click', function() {
      var $t, history, theme;
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
        history = [theme];
        return set_timers();
      }
    });
    load_theme = function(theme) {
      var $active_card, $li, i, line, new_line, pos, theme_template, _i, _len, _len2, _ref, _ref2;
      theme_template = theme.theme_templates[active_view];
      if (!theme_template) {
        if (active_view === 2) {
          theme_template = $.extend(true, {}, theme.theme_templates[0]);
        }
        if (active_view === 1) {
          theme_template = $.extend(true, {}, theme.theme_templates[0]);
          _ref = theme_template.lines;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            line = _ref[_i];
            $.extend(true, line, {
              h: line.h / 1.5,
              w: line.w / 1.5
            });
            new_line = $.extend(true, {}, line);
            new_line.x = 100 - new_line.x - new_line.w;
            theme_template.lines.push(new_line);
          }
          theme_template.qr.h = theme_template.qr.h / 1.5;
          theme_template.qr.w = theme_template.qr.w / 1.5;
        }
        theme.theme_templates[active_view] = theme_template;
      }
      if (active_view === 1 && theme.theme_templates[active_view].lines.length > 10) {
        theme.theme_templates[active_view].lines.splice(10, 5);
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
        $card.css({
          height: 280,
          width: 505,
          padding: 10,
          margin: 0
        });
        update_card_size();
      }
      $qr.hide();
      $lines.hide();
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
      _ref2 = theme_template.lines;
      for (i = 0, _len2 = _ref2.length; i < _len2; i++) {
        pos = _ref2[i];
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
      $active_card = $.create_card_from_theme(active_theme, {
        height: 300,
        width: 525
      });
      $('.my_card').children().remove();
      $('.my_card').append($active_card);
      $active_card.find('.qr canvas').css({
        left: 0,
        margin: 0
      });
      /*
          TODO
      
          - this probably doesn't need to update every time. Could make page faster not doing this.
      */
      return $lines.each(function(i) {
        return update_cards(i, $(this).html());
      });
    };
    input_timer = 0;
    set_timers = function() {
      clearTimeout(input_timer);
      return input_timer = setTimeout(function() {
        var $q, $s, values;
        $q = $('.quantity input:checked');
        $s = $('.shipping_method input:checked');
        values = $.makeArray($lines.map(function() {
          return $(this).html();
        }));
        $.ajax({
          url: '/save-form',
          data: JSON.stringify({
            values: values,
            active_view: active_view,
            active_theme_id: active_theme._id,
            quantity: $q.val(),
            shipping_method: $s.val()
          })
        });
        return false;
      }, 1000);
    };
    /*
      Update Cards
    
      This is used each time we need to update all the cards on the home page with the new content that's typed in.
    */
    update_cards = function(rowNumber, value) {
      return $('.categories .card').add('.order_total .card').each(function() {
        var $t;
        $t = $(this);
        return $t.find('.line:eq(' + rowNumber + ')').html(value);
      });
    };
    shift_pressed = false;
    $lines.each(function(i) {
      var $t;
      $t = $(this);
      $t.data('timer', 0);
      return $t.click(function() {
        var $input, remove_input, style;
        if (i === 6) $view_buttons.filter(':last').click();
        style = $t.attr('style');
        $input = $('<input class="line" />');
        $input.attr('style', style);
        $input.val($t.html());
        $t.after($input);
        $t.hide();
        $input.focus().select();
        $input.keydown(function(e) {
          var $next;
          if (e.keyCode === 16) shift_pressed = true;
          if (e.keyCode === 13 || e.keyCode === 9) {
            e.preventDefault();
            $next = $t.nextAll('div:visible:first');
            if (shift_pressed) {
              $next = $t.prev();
              if (!$next.length) $next = $lines.filter(':visible:last');
            } else {
              /*
                          Uncomment this to allow entering to 10 mode
                          if i is 5
                            $next = $t.nextAll('div:first')
              */
              if (!$next.length) $next = $lines.filter(':first');
            }
            $next.click();
            return false;
          }
        });
        $input.keyup(function(e) {
          if (e.keyCode === 16) shift_pressed = false;
          update_cards(i, this.value);
          $t.html(this.value);
          return set_timers();
        });
        remove_input = function(e) {
          var $target;
          $target = $(e.target);
          if ($target[0] !== $t[0] && $target[0] !== $input[0]) {
            $body.unbind('click', remove_input);
            $input.remove();
            return $t.show();
          }
        };
        return $body.bind('click', remove_input);
      });
    });
    $existing_payment = $('.existing_payment');
    $existing_payment.find('.button').click(function() {
      $existing_payment.remove();
      $('.order_total form').show();
      return false;
    });
    if ($existing_payment.length) $('.order_total form').hide();
    /*
      # Radio Button Clicking Stuff
    */
    $('.quantity input,.shipping_method input').bind('change', function() {
      var $q, $s;
      $q = $('.quantity input:checked');
      $s = $('.shipping_method input:checked');
      $('.order_total .price').html('$' + (($q.val() * 1) + ($s.val() * 1)));
      return set_timers();
    });
    address_timer = 0;
    set_address_timer = function() {
      clearTimeout(address_timer);
      return address_timer = setTimeout(function() {
        var address, city;
        address = $address.val();
        city = $city.val();
        if (address === '') {
          return $address.show_tooltip({
            message: 'Please enter a street address'
          });
        } else if (city === '') {
          if ($address.data('tooltip')) $address.data('tooltip').stop().hide();
          return $city.show_tooltip({
            message: 'Please enter a city or zip code'
          });
        } else {
          if ($address.data('tooltip')) $address.data('tooltip').stop().hide();
          if ($city.data('tooltip')) $city.data('tooltip').stop().hide();
          $address_result.html('Searching for real address ...');
          return $.ajax({
            url: '/find-address',
            data: JSON.stringify({
              address: address,
              city: city
            }),
            success: function(result) {
              if (result.full_address) {
                return $address_result.html(result.full_address);
              } else {
                return $address_result.html('Not found - try again?');
              }
            },
            error: function() {
              return $address_result.html(address + '<br>' + city);
            }
          });
        }
      }, 1000);
    };
    $address.keyup(set_address_timer);
    $city.keyup(set_address_timer);
    $win = $(window);
    $mc = $('.home_designer');
    $view_buttons.click(function() {
      var $t, index;
      $t = $(this);
      $view_buttons.filter('.active').removeClass('active');
      $t.addClass('active');
      index = $t.prevAll().length;
      active_view = index;
      load_theme(active_theme);
      return set_timers();
    });
    /*
      Shopping Cart Stuff
    */
    item_name = '100 cards';
    return $('.checkout').click(function() {
      $.load_loading({}, function(loading_close) {
        return $.ajax({
          url: '/validate-purchase',
          success: function(result) {
            var $s;
            if (result.error) {
              loading_close();
              if (result.error === 'Please sign in') {
                $s = $('.signins');
                return $('html,body').animate({
                  scrollTop: $s.offset().top - 50
                }, 500, function() {
                  $s.stop(true, true).delay(300).fadeOut().fadeIn().fadeOut().fadeIn().fadeOut().fadeIn();
                  return $s.show_tooltip({
                    message: 'Please sign in or create an account.'
                  });
                });
              } else {
                return $.load_alert({
                  content: result.error
                });
              }
            } else if (result.success) {
              if ($('.existing_payment').length) {
                return document.location.href = '/thank-you';
              } else {
                return $('.order_total form').submit();
              }
            } else {
              loading_close();
              return $.load_alert({
                content: 'Our apoligies, something went wrong, please try again later'
              });
            }
          },
          error: function() {
            loading_close();
            return $.load_alert({
              content: 'Our apoligies, somethieng went wrong, please try again later'
            });
          }
        });
      });
      return false;
    });
  });

}).call(this);
