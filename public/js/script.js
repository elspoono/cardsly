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

  var $window, date_format, usualDelay;

  $.ajaxSetup({
    type: 'POST'
  });

  usualDelay = 4000;

  $window = $(window);

  $.fx.speeds._default = 300;

  if ($.browser.msie && parseInt($.browser.version, 10) < 8) {
    document.location.href = '/splash';
  }

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
      size = count * scale + scale * 2;
      $t.css({
        height: size,
        width: size
      });
      $canvas.attr({
        height: size,
        width: size
      });
      if (typeof G_vmlCanvasManager !== 'undefined') {
        return G_vmlCanvasManager.initElement($canvas[0]);
      }
    });
  };

  $.fn.draw_qr = function(options) {
    var settings;
    settings = {
      color: '000000'
    };
    return this.each(function(i) {
      var $t, c, count, ctx, cutHex, hexToB, hexToG, hexToR, qrcode, r, scale, size, _ref, _results;
      if (options) $.extend(settings, options);
      $t = $(this);
      qrcode = $t.data('qrcode');
      count = qrcode.getModuleCount();
      scale = 3;
      size = count * scale + scale * 2;
      ctx = $t.find('canvas')[0].getContext("2d");
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
              _results2.push(ctx.fillRect(r * scale + scale, c * scale + scale, scale, scale));
            } else {
              _results2.push(void 0);
            }
          }
          return _results2;
        })());
      }
      return _results;
    });
  };

  $.fn.qr = function(options) {
    var settings;
    settings = {
      color: '000000',
      url: 'http://cards.ly'
    };
    return this.each(function(i) {
      var $t;
      if (options) $.extend(settings, options);
      $t = $(this);
      $t.prep_qr({
        url: settings.url
      });
      return $t.draw_qr({
        color: settings.color
      });
    });
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
      return tooltip.stop(true, true).fadeIn().delay(usualDelay).fadeOut();
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
    var $body, buttons, close, height, i, modal, my_next, resize_event, scrollbar_width, settings, this_button, width, win, _i, _len, _ref;
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
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        this_button = $('<input type="button" class="button" value="' + i.label + '" class="submit">');
        if (i["class"]) {
          this_button.addClass(i["class"]);
        } else {
          this_button.addClass('normal');
        }
        this_button.click(function() {
          return i.action(my_next);
        });
        buttons.append(this_button);
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
    var days, decode, result, t;
    if (arguments.length > 1 && String(value) !== "[object Object]") {
      options = jQuery.extend({}, options);
      if (value === null || value === void 0) options.expires = -1;
      if (typeof options.expires === 'number') {
        days = options.expires;
        t = options.expires = new Date();
        t.setDate(t.getDate() + days);
      }
      value = String(value);
      document.cookie = [encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value), options.expires ? '; expires=' + options.expires.toUTCString() : '', options.path ? '; path=' + options.path : 'path=/', options.domain ? '; domain=' + options.domain : '', options.secure ? '; secure' : ''].join('');
    }
    options = value || {};
    decode = options.raw ? function(s) {
      return s;
    } : decodeURIComponent;
    if ((result = new RegExp('(?:^| )' + encodeURIComponent(key) + '=([^]*)').exec(document.cookie))) {
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
    /*
      Profile MENU in the TOP RIGHT
      Thing that shows a drop down
    */
    var $a, $am, $body, $feedback_a, close_menu, expand_menu, monitor_for_complete, path, successful_login;
    $a = $('.account_link');
    $am = $a.find('.account_menu');
    $body = $(document);
    $('.small_nav li').hover(function() {
      return $(this).addClass('hover');
    }, function() {
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
      if (path !== '/') {
        document.location.href = '/#design-button';
      } else {
        $('html,body').animate({
          scrollTop: $('.section:eq(1)').offset().top
        }, 500);
      }
      return false;
    });
    if (path === '/#design-button') {
      document.location.href = '#';
      $('.design_button').click();
    }
    successful_login = function() {
      var $s;
      if (path === '/login') {
        return document.location.href = '/admin';
      } else {
        $s = $('.signins');
        $s.fadeOut(500, function() {
          $s.html('You are now logged in, please continue.');
          return $s.fadeIn(1000);
        });
        return $('.login a').attr('href', '/logout').html('Logout');
      }
    };
    /*
      Login stuff
    */
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
          data: {
            email: $('.email_login').val(),
            password: $('.password_login').val()
          },
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
                    data: {
                      email: email.val(),
                      password: password.val()
                    },
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
              data: {
                email: $t.val()
              },
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
      return $feedback.stop(true, false).animate({
        right: '-37px'
      }, 250);
    });
    $feedback_a.mouseout(function() {
      var $feedback;
      $feedback = $('.feedback');
      return $feedback.stop(true, false).animate({
        right: '-45px'
      }, 250);
    });
    $feedback_a.click(function() {
      $.load_modal({
        content: '<div class="feedback_form"><h2>Feedback:</h2><textarea cols="40" rows="10" class="feedback_text" placeholder="Type any feedback you may have here"></textarea><p><h2>Email:</h2><input type="email" class="emailNotUser" placeholder="Please enter your email" cols="40"></p></div>',
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
                  data: {
                    content: $('.feedback_text').val(),
                    email: $('.emailNotUser').val()
                  },
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
    return $('.button').live('mouseenter', function() {
      return $(this).addClass('hover');
    }).live('mouseleave', function() {
      return $(this).removeClass('hover');
    }).live('mousedown', function() {
      return $(this).addClass('click');
    }).live('mouseup', function() {
      return $(this).removeClass('click');
    });
  });

}).call(this);
