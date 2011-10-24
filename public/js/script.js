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
    var $body, Close, buttons, cancel, close, confirm, height, modal, myNext, ok, resizeEvent, scrollbarWidth, settings, width, win;
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
    if (settings.Close) {
      Close = $('<input type="button" value="Close" class="submit">');
      Close.click(function() {
        return settings.Close(myNext);
      });
      buttons.append(Close);
    }
    if (settings.Ok) {
      ok = $('<input type="button" value="Ok" class="submit">');
      ok.click(function() {
        return settings.Ok(myNext);
      });
      buttons.append(ok);
    }
    if (settings.Cancel) {
      cancel = $('<input type="button" value="Cancel" class="cancel">');
      cancel.click(function() {
        return settings.Cancel(myNext);
      });
      buttons.append(cancel);
    }
    if (settings.Confirm) {
      confirm = $('<input type="button" value="Confirm" class="submit">');
      confirm.click(function() {
        return settings.Confirm(myNext);
      });
      buttons.append(confirm);
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
      Ok: function(close) {
        return close();
      },
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
  $(function() {
    var $win, advanceSlide, hasHidden, i, marginIncrement, maxSlides, newMargin, timer, winH, _i, _len;
    $('.google').click(function() {
      window.open('auth/google', 'auth', 'height=350,width=600');
      return false;
    });
    $('.twitter').click(function() {
      window.open('auth/twitter', 'auth', 'height=400,width=500');
      return false;
    });
    $('.facebook').click(function() {
      window.open('auth/facebook', 'auth', 'height=400,width=900');
      return false;
    });
    $('.linkedin').click(function() {
      window.open('auth/linkedin', 'auth', 'height=300,width=400');
      return false;
    });
    $('.new').click(function() {
      loadAlert({
        content: '<iframe height=400 width=100% src=/login ></iframe>',
        height: 400,
        width: 700
      });
      return false;
    });
    $win = $(window);
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
    $win.scroll(function() {
      var i, newWinH, _j, _len2, _results;
      newWinH = $win.height() + $win.scrollTop();
      _results = [];
      for (_j = 0, _len2 = hasHidden.length; _j < _len2; _j++) {
        i = hasHidden[_j];
        _results.push(i.thisT - 50 < newWinH ? i.$this.fadeIn(2000) : void 0);
      }
      return _results;
    });
    $('.button').hover(function() {
      return $(this).addClass('hover');
    }, function() {
      return $(this).removeClass('hover');
    }).mousedown(function() {
      return $(this).addClass('click');
    }).mouseup(function() {
      return $(this).removeClass('click');
    });
    newMargin = 0;
    maxSlides = 3;
    marginIncrement = 620;
    maxSlides--;
    $('.design-button.top').click(function() {
      $('html,body').animate({
        scrollTop: $('.section:eq(1)').offset().top
      }, 1000);
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
