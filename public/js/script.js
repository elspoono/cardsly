(function() {
  /*
   * 
   * Set settings / defaults
   * 
   * AJAX defaults
   * some constants
   * 
  */
  var $window, dateFormat, loadAlert, loadConfirm, loadLoading, loadModal, usualDelay;
  $.ajaxSetup({
    type: 'POST'
  });
  usualDelay = 4000;
  $window = $(window);
  $.fx.speeds._default = 300;
  /*
   * 
   * Modal Handling Functions
   * 
   * show tooltip, can be used on any element with jquery
   * 
   * 
  */
  $.fn.showTooltip = function(options) {
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
        tooltip = data[data.length - 1];
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
  loadModal = function(options, next) {
    var $body, buttons, close, height, i, modal, myNext, resizeEvent, scrollbarWidth, settings, thisButton, width, win, _i, _len, _ref;
    scrollbarWidth = $.scrollbarWidth();
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
    myNext = function() {
      $window.unbind('scroll resize', resizeEvent);
      $window.unbind('resize', resizeEvent);
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
        thisButton = $('<input type="button" class="button normal" value="' + i.label + '" class="submit">');
        thisButton.click(function() {
          return i.action(myNext);
        });
        buttons.append(thisButton);
      }
    }
    win.append(buttons);
    $('body').append(modal, close, win);
    $body = $('body');
    resizeEvent = function() {
      var height, top, width;
      width = $window.width();
      height = $window.height();
      if (width < settings.width || height < win.height()) {
        $window.unbind('scroll resize', resizeEvent);
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
          'padding-right': scrollbarWidth
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
    $window.bind('resize scroll', resizeEvent);
    modal.click(myNext);
    close.click(myNext);
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
      next(myNext);
    }
    return resizeEvent();
  };
  /*
   * 
   * Modal Handling Functions
   * 
   * Load Loading (Subclass of loadmodal)
   * 
   * 
  */
  loadLoading = function(options, next) {
    var i, modifiedOptions, v;
    options = options || {};
    modifiedOptions = {
      content: 'Loading ... ',
      height: 100,
      width: 200
    };
    for (i in options) {
      v = options[i];
      modifiedOptions[i] = options[i];
    }
    return loadModal(modifiedOptions, next);
  };
  /*
   * 
   * Modal Handling Functions
   * 
   * Load Confirm (Subclass of loadmodal)
   * like javascript confirm()
   * 
  */
  loadConfirm = function(options, next) {
    var i, modifiedOptions, v;
    options = options || {};
    modifiedOptions = {
      content: 'Confirm',
      height: 80,
      width: 300
    };
    for (i in options) {
      v = options[i];
      modifiedOptions[i] = options[i];
    }
    return loadModal(modifiedOptions, next);
  };
  /*
   * 
   * Modal Handling Functions
   * 
   * Load Alert (Subclass of loadmodal)
   * like javascript alert()
   * 
  */
  loadAlert = function(options, next) {
    var i, modifiedOptions, v;
    options = options || {};
    next = next || function() {};
    if (typeof options === 'string') {
      options = {
        content: options
      };
    }
    modifiedOptions = {
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
      modifiedOptions[i] = options[i];
    }
    return loadModal(modifiedOptions, next);
  };
  /*
   * jQuery Scrollbar Width v1.0
   * 
   * Copyright 2011, Rasmus Schultz
   * Licensed under LGPL v3.0
   * http:#www.gnu.org/licenses/lgpl-3.0.txt
  */
  $.scrollbarWidth = function() {
    var $body, w;
    if (!$._scrollbarWidth) {
      $body = $('body');
      w = $body.css('overflow', 'hidden').width();
      $body.css('overflow', 'scroll');
      w -= $body.width();
      if (!w) {
        w = $body.width() - $body[0].clientWidth;
      }
      $body.css('overflow', '');
      $._scrollbarWidth = w;
    }
    return $._scrollbarWidth;
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
   * The mask defaults to dateFormat.masks.default.
  */
  dateFormat = (function() {
    var pad, timezone, timezoneClip, token;
    function dateFormat() {}
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
    dateFormat.prototype.format = function(date, mask, utc) {
      var D, H, L, M, d, dF, flags, m, o, s, y, _;
      dF = dateFormat.prototype;
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
    dateFormat.prototype.masks = {
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
    dateFormat.prototype.i18n = {
      dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    };
    return dateFormat;
  })();
  Date.prototype.format = function(mask, utc) {
    var a;
    a = new dateFormat;
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
  $(function() {
    var $gs, $mc, $win, advanceSlide, hasHidden, i, item_name, marginIncrement, maxSlides, monitorForComplete, newMargin, path, successfulLogin, timer, updateCards, winH, _i, _len;
    path = document.location.href.replace(/http:\/\/[^\/]*/ig, '');
    $('.design-button').click(function() {
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
      $('.design-button').click();
    }
    successfulLogin = function() {
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
    hasHidden = [];
    $('.section-to-hide').each(function() {
      var $this, thisT;
      $this = $(this);
      thisT = $this.offset().top;
      if (winH < thisT) {
        return hasHidden.push({
          $this: $this,
          thisT: thisT
        });
      }
    });
    for (_i = 0, _len = hasHidden.length; _i < _len; _i++) {
      i = hasHidden[_i];
      i.$this.hide();
    }
    /*
      Update Cards
    
      Function used a few places below
      */
    updateCards = function(rowNumber, value) {
      return $('.card .content').each(function() {
        return $(this).find('li:eq(' + rowNumber + ')').html(value);
      });
    };
    $win.scroll(function() {
      var i, newWinH, timeLapse, _j, _len2, _results;
      newWinH = $win.height() + $win.scrollTop();
      if ($mc.length) {
        if ($mc.offset().top + $mc.height() < newWinH && !$mc.data('didLoad')) {
          $mc.data('didLoad', true);
          timeLapse = 0;
          $('.main.card').find('input').each(function(rowNumber) {
            return updateCards(rowNumber, this.value);
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
                    return updateCards(rowNumber, v_substring);
                  }, timeLapse * 70);
                  timeLapse++;
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
                updateCards(rowNumber, '');
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
      for (_j = 0, _len2 = hasHidden.length; _j < _len2; _j++) {
        i = hasHidden[_j];
        _results.push(i.thisT - 50 < newWinH ? i.$this.fadeIn(2000) : void 0);
      }
      return _results;
    });
    /*
      Login stuff
      */
    monitorForComplete = function(openedWindow) {
      var checkTimer;
      $.cookie('success-login', null);
      return checkTimer = setInterval(function() {
        if ($.cookie('success-login')) {
          successfulLogin();
          $.cookie('success-login', null);
          window.focus();
          return openedWindow.close();
        }
      }, 200);
    };
    $('.google').click(function() {
      monitorForComplete(window.open('auth/google', 'auth', 'height=350,width=600'));
      return false;
    });
    $('.twitter').click(function() {
      monitorForComplete(window.open('auth/twitter', 'auth', 'height=400,width=500'));
      return false;
    });
    $('.facebook').click(function() {
      monitorForComplete(window.open('auth/facebook', 'auth', 'height=400,width=900'));
      return false;
    });
    $('.linkedin').click(function() {
      monitorForComplete(window.open('auth/linkedin', 'auth', 'height=300,width=400'));
      return false;
    });
    $('.login-form').submit(function() {
      loadLoading({}, function(loadingClose) {
        return $.ajax({
          url: '/login',
          data: {
            email: $('.email-login').val(),
            password: $('.password-login').val()
          },
          success: function(data) {
            loadingClose();
            if (data.err) {
              return loadAlert({
                content: data.err
              });
            } else {
              return successfulLogin();
            }
          },
          error: function(err) {
            loadingClose();
            return loadAlert({
              content: 'Our apologies. A server error occurred.'
            });
          }
        });
      });
      return false;
    });
    $('.new').click(function() {
      loadModal({
        content: '<div class="create-form"><p>Email Address:<br><input class="email"></p><p>Password:<br><input type="password" class="password"></p></p><p>Repeat Password:<br><input type="password" class="password2"></p></div>',
        buttons: [
          {
            label: 'Create New',
            action: function(formClose) {
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
                return loadAlert({
                  content: err
                });
              } else {
                formClose();
                return loadLoading({}, function(loadingClose) {
                  return $.ajax({
                    url: '/createUser',
                    data: {
                      email: email.val(),
                      password: password.val()
                    },
                    success: function(data) {
                      loadingClose();
                      if (data.err) {
                        return loadAlert({
                          content: 'Our apologies. A server error occurred.'
                        });
                      } else {
                        return successfulLogin();
                      }
                    },
                    error: function(err) {
                      loadingClose();
                      return loadAlert({
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
              success: function(data) {
                if (data.data === 0) {
                  $t.removeClass('error').addClass('valid');
                  return $t.showTooltip({
                    message: data.email + ' is good'
                  });
                } else {
                  $t.removeClass('valid').addClass('error');
                  return $t.showTooltip({
                    message: '' + data.email + ' already has an account. Try signing in please?'
                  });
                }
              }
            });
          } else {
            return $t.removeClass('valid').addClass('error').showTooltip({
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
            return $t.removeClass('valid').addClass('error').showTooltip({
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
            return $('.step-4').fadeTo(300, 1);
          } else {
            return $t.removeClass('valid').addClass('error').showTooltip({
              message: 'Passwords should match please.'
            });
          }
        }, 1000));
      });
      return false;
    });
    /*
      Shopping Cart Stuff
      */
    item_name = '100 cards';
    $('.checkout').click(function() {
      loadAlert({
        content: '<p>Our apologies - we are still in development.<p>Please check back next week!<p>(November 5th 2011)'
      });
      return false;
    });
    $gs = $('.gallery-select');
    $gs.css({
      left: -220,
      top: 0
    });
    $('.gallery .card').click(function() {
      var $findClass, $t, className;
      $t = $(this);
      $('.card').removeClass('active');
      $t.addClass('active');
      $findClass = $t.clone();
      className = $findClass.removeClass('card')[0].className;
      $findClass.remove();
      $('.main').attr({
        "class": 'card main ' + className
      });
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
    $gs.bind('activeMoved', function() {
      var $a;
      $a = $('.card.active');
      return $gs.css({
        left: $a.offset().left - 10,
        top: $a.offset().top - 10
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
    newMargin = 0;
    maxSlides = 3;
    marginIncrement = 620;
    maxSlides--;
    /*
      # Home Page Stuff
      */
    $('.category h4').click(function() {
      var $a, $c, $g, $t;
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
        updateCards(i, this.value);
        clearTimeout($t.data('timer'));
        $t.data('timer', setTimeout(function() {
          var arrayOfInputValues;
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
          arrayOfInputValues = $.makeArray($('.card.main input').map(function() {
            return this.value;
          }));
          console.log(arrayOfInputValues);
          $.ajax({
            url: '/saveForm',
            data: {
              inputs: arrayOfInputValues.join('`~`')
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
      return $('.order-total .price').html('$' + ($q.val() * 1 + $s.val() * 1));
    });
    $('.main-fields .more').click(function() {
      $('.main-fields .alt').slideDown(500, 'linear', function() {
        return $('.gallery .card.active').click();
      });
      $(this).hide();
      $('.main-fields .less').show();
      return false;
    });
    $('.main-fields .less').hide().click(function() {
      $('.main-fields .alt').slideUp(500, 'linear', function() {
        return $('.gallery .card.active').click();
      });
      $(this).hide();
      $('.main-fields .more').show();
      return false;
    });
    advanceSlide = function() {
      if (newMargin < maxSlides * -marginIncrement) {
        newMargin = 0;
      } else if (newMargin > 0) {
        newMargin = maxSlides * -marginIncrement;
      }
      return $('.slides .content').stop(true, false).animate({
        'margin-left': newMargin
      }, 400);
    };
    $('.slides .arrow-right').click(function() {
      marginIncrement = $('.slides').width();
      clearTimeout(timer);
      newMargin -= marginIncrement;
      return advanceSlide();
    });
    $('.slides .arrow-left').click(function() {
      marginIncrement = $('.slides').width();
      clearTimeout(timer);
      newMargin -= -marginIncrement;
      return advanceSlide();
    });
    return timer = setTimeout(function() {
      marginIncrement = $('.slides').width();
      newMargin -= marginIncrement;
      advanceSlide();
      clearTimeout(timer);
      return timer = setInterval(function() {
        marginIncrement = $('.slides').width();
        newMargin -= marginIncrement;
        return advanceSlide();
      }, 6500);
    }, 3000);
  });
}).call(this);
