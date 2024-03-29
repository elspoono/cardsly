###
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
###
class date_format
  token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g
  timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g
  timezoneClip = /[^-+\dA-Z]/g
  pad = (val, len) ->
    val = String(val)
    len = len || 2
    while val.length < len
      val = "0" + val
    val
  format: (date, mask, utc) ->
    dF = date_format.prototype

    # You can't provide utc if you skip other args (use the "UTC:" mask prefix)
    if arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)
      mask = date
      date = undefined

    # Passing date through Date applies Date.parse, if necessary
    date = if date then new Date(date) else new Date
    if isNaN(date) 
      throw SyntaxError "invalid date"

    mask = String dF.masks[mask] || mask || dF.masks["default"]

    # Allow setting the utc argument via the mask
    if mask.slice(0, 4) == "UTC:"
      mask = mask.slice(4)
      utc = true

    _ = if utc then "getUTC" else "get"
    d = date[_ + "Date"]()
    D = date[_ + "Day"]()
    m = date[_ + "Month"]()
    y = date[_ + "FullYear"]()
    H = date[_ + "Hours"]()
    M = date[_ + "Minutes"]()
    s = date[_ + "Seconds"]()
    L = date[_ + "Milliseconds"]()
    o = utc ? 0 : date.getTimezoneOffset()
    flags =
      d:    d
      dd:   pad d
      ddd:  dF.i18n.dayNames[D]
      dddd: dF.i18n.dayNames[D + 7]
      m:    m + 1
      mm:   pad m + 1
      mmm:  dF.i18n.monthNames[m]
      mmmm: dF.i18n.monthNames[m + 12]
      yy:   String(y).slice 2
      yyyy: y
      h:    H % 12 || 12
      hh:   pad H % 12 || 12
      H:    H
      HH:   pad H
      M:    M
      MM:   pad M
      s:    s
      ss:   pad s
      l:    pad L, 3
      L:    pad if L > 99 then Math.round L / 10 else L
      t:    if H < 12 then "a"  else "p"
      tt:   if H < 12 then "am" else "pm"
      T:    if H < 12 then "A"  else "P"
      TT:   if H < 12 then "AM" else "PM"
      Z:    if utc then "UTC" else (String(date).match(timezone) || [""]).pop().replace(timezoneClip, "")
      o:    (if o > 0 then "-" else "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4)
      S:    ["th", "st", "nd", "rd"][if d % 10 > 3 then 0 else (d % 100 - d % 10 != 10) * d % 10]
    mask.replace token, ($0) ->
      if flags then flags[$0] else $0.slice(1, $0.length - 1)
  # Some common format strings
  masks :
    default:      "ddd mmm dd yyyy HH:MM:ss"
    shortDate:      "m/d/yy"
    mediumDate:     "mmm d, yyyy"
    longDate:       "mmmm d, yyyy"
    fullDate:       "dddd, mmmm d, yyyy"
    shortTime:      "h:MM TT"
    mediumTime:     "h:MM:ss TT"
    longTime:       "h:MM:ss TT Z"
    isoDate:        "yyyy-mm-dd"
    isoTime:        "HH:MM:ss"
    isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss"
    isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
  # Internationalization strings
  i18n :
    dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
#
ago = (distanceMillis) ->
  substitute = (stringOrFunction, number) ->
    string = (if typeof(stringOrFunction) is 'function' then stringOrFunction(number, distanceMillis) else stringOrFunction)
    value = ($l.numbers and $l.numbers[number]) or number
    string.replace /%d/i, value
  $l = 
    prefixAgo: null
    prefixFromNow: null
    suffixAgo: ""
    suffixFromNow: "from now"
    seconds: "just now"
    minute: "a minute ago"
    minutes: "%d minutes ago"
    hour: "an hour ago"
    hours: "%d hours ago"
    day: "a day ago"
    days: "%d days ago"
    month: "a month ago"
    months: "%d months ago"
    year: "a year ago"
    years: "%d years ago"
    numbers: []
  prefix = $l.prefixAgo
  suffix = $l.suffixAgo
  seconds = distanceMillis / 1000
  minutes = seconds / 60
  hours = minutes / 60
  days = hours / 24
  years = days / 365
  words = seconds < 45 and substitute($l.seconds, Math.round(seconds)) or seconds < 90 and substitute($l.minute, 1) or minutes < 45 and substitute($l.minutes, Math.round(minutes)) or minutes < 90 and substitute($l.hour, 1) or hours < 24 and substitute($l.hours, Math.round(hours)) or hours < 48 and substitute($l.day, 1) or days < 30 and substitute($l.days, Math.floor(days)) or days < 60 and substitute($l.month, 1) or days < 365 and substitute($l.months, Math.floor(days / 30)) or years < 2 and substitute($l.year, 1) or substitute($l.years, Math.floor(years))
  [ prefix, words, suffix ].join(" ").replace /(^ *| *$)/ig, ''
#
#
#
# For convenience...
Date::format = (mask, utc) ->
  a = new date_format
  a.format(this, mask, utc)
#
#
Date::ago = () ->
  ago new Date() - this
#
exports = date_format