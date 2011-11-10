(function() {
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
   * 
   * Modal Handling Functions
   * 
   * show tooltip, can be used on any element with jquery
   * 
   * 
  */
  $.fn.show_tooltip = function(options) {
    var settings;
    settings = {
      position: 'below'
    };
    return this.each(function(i) {
      var $t, data, offset, toRemove, tooltip, _i, _len;
      if (options) {
        $.extend(settings, options);
      }
      $t = $(this);
      offset = $t.offset();
      data = $t.data('tooltips');
      if (!data) {
        data = [];
      }
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
    settings = {
      width: 500,
      height: 235,
      closeText: 'close'
    };
    if (options) {
      $.extend(settings, options);
    }
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
        if ($('.window').length === 0) {
          return $('#container').show();
        }
      });
    };
    if (settings.closeText) {
      close.html(settings.closeText);
    }
    if (settings.content) {
      win.html(settings.content);
    }
    if (settings.height) {
      win.css({
        'min-height': settings.height
      });
    }
    if (settings.width) {
      win.width(settings.width);
    }
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
    $body = $('body');
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
    if (next) {
      next(my_next);
    }
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
      if (!w) {
        w = $body.width() - $body[0].clientWidth;
      }
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
      if (isNaN(date)) {
        throw SyntaxError("invalid date");
      }
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
      if (value === null || value === void 0) {
        options.expires = -1;
      }
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
      if (options) {
        $.extend(settings, options);
      }
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
  
  
  THIS IS WHERE REAL CODE STARTS
  
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
    var $a, $am, $body, $feedback_a, $gs, $mc, $slides, $win, advance_slide, close_menu, expand_menu, has_hidden, i, item_name, margin_increment, max_slides, monitor_for_complete, new_margin, path, successful_login, timer, update_cards, winH, _i, _len;
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
        $am.slideUp();
        $a.one('click', expand_menu);
        $body.unbind('click', close_menu);
      }
      return false;
    };
    expand_menu = function() {
      $am.slideDown();
      $a.addClass('click');
      $body.bind('click', close_menu);
      return false;
    };
    $a.one('click', expand_menu);
    /*
      Multiple
      Lines Of
      Comments
      */
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
    $win = $(window);
    $mc = $('.main.card');
    winH = $win.height() + $win.scrollTop();
    has_hidden = [];
    $('.section_to_hide').each(function() {
      var $this, thisT;
      $this = $(this);
      thisT = $this.offset().top;
      if (winH < thisT) {
        return has_hidden.push({
          $this: $this,
          thisT: thisT
        });
      }
    });
    for (_i = 0, _len = has_hidden.length; _i < _len; _i++) {
      i = has_hidden[_i];
      i.$this.hide();
    }
    /*
      Update Cards
    
      This is used each time we need to update all the cards on the home page with the new content that's typed in.
      */
    update_cards = function(rowNumber, value) {
      return $('.card .content').each(function() {
        return $(this).find('li:eq(' + rowNumber + ')').html(value);
      });
    };
    $win.scroll(function() {
      var i, newWinH, time_lapse, _j, _len2, _results;
      newWinH = $win.height() + $win.scrollTop();
      if ($mc.length) {
        if ($mc.offset().top + $mc.height() < newWinH && !$mc.data('didLoad')) {
          $mc.data('didLoad', true);
          time_lapse = 0;
          $('.main.card').find('input').each(function(rowNumber) {
            return update_cards(rowNumber, this.value);
          });
          $('.main.card .defaults').find('input').each(function(rowNumber) {
            var $t, j, timers, v;
            $t = $(this);
            v = $t.val();
            $t.val('');
            timers = (function() {
              var _ref, _results;
              _results = [];
              for (j = 0, _ref = v.length; 0 <= _ref ? j <= _ref : j >= _ref; 0 <= _ref ? j++ : j--) {
                _results.push((function(j) {
                  var timer;
                  timer = setTimeout(function() {
                    var v_substring;
                    v_substring = v.substr(0, j);
                    $t.val(v_substring);
                    return update_cards(rowNumber, v_substring);
                  }, time_lapse * 70);
                  time_lapse++;
                  return timer;
                })(j));
              }
              return _results;
            })();
            $t.bind('clearMe', function() {
              var i, _j, _len2;
              console.log($t.data('cleared'));
              if (!$t.data('cleared')) {
                for (_j = 0, _len2 = timers.length; _j < _len2; _j++) {
                  i = timers[_j];
                  clearTimeout(i);
                }
                $t.val('');
                update_cards(rowNumber, '');
                return $t.data('cleared', true);
              }
            });
            return $t.bind('focus', function() {
              return $t.trigger('clearMe');
            });
          });
        }
      }
      _results = [];
      for (_j = 0, _len2 = has_hidden.length; _j < _len2; _j++) {
        i = has_hidden[_j];
        _results.push(i.thisT_50 < newWinH ? i.$this.fadeIn(2000) : void 0);
      }
      return _results;
    });
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
                    url: '/createUser',
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
                  }, 1000);
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
              url: '/checkEmail',
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
    $('.change_password_button').click(function() {
      var current_password, err, password;
      current_password = $('.current_password');
      password = $('.password');
      password = $('.password_retyped');
      err = false;
      if (password.val() !== password2.val()) {
        return err = 'I\'m sorry, I don\'t think those passwords match.';
      } else if (password.val().length < 4) {
        return err = 'Password should be a little longer, at least 4 characters.';
      } else if (err) {
        return loadAlert({
          content: err
        });
      } else {
        return current_password = password.val();
      }
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
                  url: '/sendFeedback',
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
    $('#show_activity').change(function() {
      var e;
      $('#activity_container ul').hide('slow');
      e = '#' + $(':selected', $(this)).attr('name');
      return $(e).show('slow');
    });
    $('#activity_container ul').hide();
    $('#show_card_chart').change(function() {
      var e;
      $('#chart_container ul').hide('slow');
      e = '#' + $(':selected', $(this)).attr('name');
      return $(e).show('slow');
    });
    $('#chart_container ul').hide();
    /*
      Shopping Cart Stuff
      */
    item_name = '100 cards';
    $('.checkout').click(function() {
      $.load_alert({
        content: '<p>In development.<p>Please check back <span style="text-decoration:line-through;">next week</span> <span style="text-decoration:line-through;">later this week</span> next wednesday.<p>(November 9th 2011)'
      });
      return false;
    });
    $gs = $('.gallery_select');
    $gs.css({
      left: -220,
      top: 0
    });
    $('.gallery .card').live('click', function() {
      var $find_class, $t, class_name;
      $t = $(this);
      $('.card').removeClass('active');
      $t.addClass('active');
      $find_class = $t.clone();
      class_name = $find_class.removeClass('card')[0].class_name;
      $find_class.remove();
      $('.main').attr({
        "class": 'card main ' + class_name
      });
      if ($gs.offset().top === $t.offset().top_10) {
        return $gs.animate({
          left: $t.offset().left_10
        }, 500);
      } else {
        return $gs.stop(true, false).animate({
          top: $t.offset().top_10
        }, 500, 'linear', function() {
          return $gs.animate({
            left: $t.offset().left_10
          }, 500, 'linear');
        });
      }
    });
    $gs.bind('activeMoved', function() {
      $a = $('.card.active');
      return $gs.css({
        left: $a.offset().left_10,
        top: $a.offset().top_10
      });
    });
    $(window).load(function() {
      return $('.gallery:first .card:first').click();
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
    new_margin = 0;
    max_slides = $('.slides li').length;
    margin_increment = 620;
    max_slides--;
    /*
      # Home Page Stuff
      */
    $('.category h4').click(function() {
      var $c, $g, $t;
      $t = $(this);
      $c = $t.closest('.category');
      $g = $c.find('.gallery');
      $a = $('.category.active');
      if (!$c.hasClass('active')) {
        $a.removeClass('active');
        $a.find('.gallery').show().slideUp(400);
        $gs.hide();
        $c.find('.gallery').slideDown(400, function() {
          $gs.show();
          return $c.find('.card:first').click();
        });
        return $c.addClass('active');
      }
    });
    $('.card.main input').each(function(i) {
      var $t;
      $t = $(this);
      $t.data('timer', 0);
      return $t.keyup(function() {
        update_cards(i, this.value);
        clearTimeout($t.data('timer'));
        $t.data('timer', setTimeout(function() {
          var array_oF_inpUt_values;
          $('.card.main input').each(function() {
            return $(this).trigger('clearMe');
          });
          /*
                    # TODO
                    #
                    # this.value should have a .replace ',' '\,'
                    # on it so that we can use a comma character and escape anything.
                    # more appropriate way to avoid conflicts than the current `~` which may still be randomly hit sometime.
                    */
          array_oF_inpUt_values = $.makeArray($('.card.main input').map(function() {
            return this.value;
          }));
          console.log(array_oF_inpUt_values);
          $.ajax({
            url: '/saveForm',
            data: {
              inputs: array_oF_inpUt_values.join('`~`')
            }
          });
          return false;
        }, 1000));
        return false;
      });
    });
    /*
      # Button Clicking Stuff
      */
    $('.quantity input,.shipping_method input').bind('click change', function() {
      var $q, $s;
      $q = $('.quantity input:checked');
      $s = $('.shipping_method input:checked');
      return $('.order_total .price').html('$' + ($q.val() * 1 + $s.val() * 1));
    });
    $('.main_fields .more').click(function() {
      $('.main_fields .alt').slideDown(500, 'linear', function() {
        return $('.gallery .card.active').click();
      });
      $(this).hide();
      $('.main_fields .less').show();
      return false;
    });
    $('.main_fields .less').hide().click(function() {
      $('.main_fields .alt').slideUp(500, 'linear', function() {
        return $('.gallery .card.active').click();
      });
      $(this).hide();
      $('.main_fields .more').show();
      return false;
    });
    advance_slide = function() {
      if (new_margin < max_slides * -margin_increment) {
        new_margin = 0;
      } else if (new_margin > 0) {
        new_margin = max_slides * -margin_increment;
      }
      return $('.slides .content').stop(true, false).animate({
        'margin-left': new_margin
      }, 400);
    };
    $('.slides .arrow_right').click(function() {
      margin_increment = $('.slides').width();
      clearTimeout(timer);
      new_margin -= margin_increment;
      return advance_slide();
    });
    $('.slides .arrow_left').click(function() {
      margin_increment = $('.slides').width();
      clearTimeout(timer);
      new_margin -= -margin_increment;
      return advance_slide();
    });
    timer = setTimeout(function() {
      margin_increment = $('.slides').width();
      new_margin -= margin_increment;
      advance_slide();
      clearTimeout(timer);
      return timer = setInterval(function() {
        margin_increment = $('.slides').width();
        new_margin -= margin_increment;
        return advance_slide();
      }, 6500);
    }, 3000);
    $slides = $('.slides');
    return $slides.animate({
      'padding-left': '301px'
    });
  });
}).call(this);
