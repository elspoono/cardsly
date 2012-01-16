##################################################################

###

THE APPLICATION

- pretty much everything server side is in here
- for now (intentionally for now, not lazy for now)
- we'll separate it into files later, depending on how it evolves

###

##################################################################








###########################################################
#
#
#
#
###

LIBRARY LOADING

- load in the libraries we'll use
- do basic config on all of them

###
#
#
#
log_err = (err) ->
  to_output = '-----------------------------\n'
  to_output+= 'COMPLETE:\n ' + util.inspect err
  if typeof(err) is 'object' and err.stack
    to_output+='\nSTACK:\n' + err.stack
  to_output+= '\n-----------------------------'
  console.log to_output
#
process.on 'uncaughtException', log_err
#
# Create server and export `app` as a module for other modules to require as a dependency 
# early in this file
express = require 'express'
http = require 'http'
knox = require 'knox'
util = require 'util'
fs = require 'fs'
app = module.exports = express.createServer()
#
#
twilio_client = require('twilio').RestClient
client = new twilio_client('AC7251c3043947408cb835e2643c1f518a','cfb4d275158cba5a1ff206c4df6d6c52')


#
# Image Magick for graphic editing
im = require 'imagemagick'
#
xml2json = require 'xml2json'
#
geo = require('geo')
#
#
#
#
require 'coffee-script'
#
nodemailer = require 'nodemailer'
#
nodemailer.SMTP = 
  host: 'smtp.sendgrid.net'
  port: 25
  use_authentication: true
  user: process.env.SENDGRID_USERNAME
  pass: process.env.SENDGRID_PASSWORD
  domain: process.env.SENDGRID_DOMAIN
#
#
#
#
# DATABASE
# url set
db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/staging'
#
#
# Mongoose is for everyone 
mongoose = require 'mongoose'
mongoose.connect db_uri
schema = mongoose.Schema
object_id = schema.ObjectId
#
#
qr_code = require './assets/js/libs/qrcode'
_ = require 'underscore'
node_canvas = require 'canvas'
#
#
#
#
#
#
###
UTIL
#
#
it's a useful for inspecting.
#
USAGE:
#
console.log util.inspect myVariableIWantToInspect
###
util = require 'util'
#
#
#
#
# BCRYPT for password storage
bcrypt = require 'bcrypt'
encrypted = (inString) ->
  salt = bcrypt.gen_salt_sync(10)
  bcrypt.encrypt_sync(inString, salt)
compareEncrypted = (inString,hash) ->
  bcrypt.compare_sync(inString, hash)
#
#
#
#
# Everyauth for 3rd party providers
everyauth = require 'everyauth'
Promise = everyauth.Promise
#
#
require './assets/js/libs/date'
#
#
###
Knox - AMAZON S3 Connector
Add the api keys and such
###
#
knoxClient = knox.createClient
  key: 'AKIAI2CJEBPY77CQ32AA'
  secret: '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'
  bucket: 'cardsly'
#
#
connect = require 'connect'
redis_store = require('connect-redis') connect
#
redis_options =
  host: 'localhost'
  port: 6379
if process.env.REDISTOGO_URL
  redis_options = 
    host: process.env.REDISTOGO_URL.replace /.*@([^:]*).*/ig, '$1'
    port: process.env.REDISTOGO_URL.replace /.*@.*:([^\/]*).*/ig, '$1'
    pass: process.env.REDISTOGO_URL.replace /.*:.*:(.*)@.*/ig, '$1'
session_store = new redis_store redis_options
#
#
redis = require 'redis'
#
#
redis_pub = redis.createClient redis_options.port, redis_options.host
if redis_options.pass
  redis_pub.auth redis_options.pass, maybe_log_err
redis_pub.on 'error', log_err
#
#
#
short_domain = 'http://cards.ly/'
if process.env and process.env.SHORT_URL
  short_domain = 'http://'+process.env.SHORT_URL+'/'
#
#
# MOO API Key
moo_auth =
  key: '4739b76c5a56a3c0f03bfcefd3248ed804ed95ae2'
  # 
  # MOO Secret
  secret: 'bec6f97d58f1121cd90e16502e6c8e4e'
#
#
# END LIBRARY LOADING
#
#
###########################################################




###########################################################
#
#
#
#
#
###

Allow pdfkit to accept buffers for images instead of reading from files

###
#
#
#
#
#
pdf_document = require 'pdfkit'
fs = require("fs")
Data = require("pdfkit/lib/data")
JPEG = require("pdfkit/lib/image/jpeg")
PNG = require("pdfkit/lib/image/png")
pdf_image = (->
  pdf_image = ->
  pdf_image.open = (filename) ->
    data = undefined
    firstByte = undefined
    if typeof filename is "string"
      @contents = fs.readFileSync(filename)
      return  unless @contents
      @data = new Data(@contents)
    else if typeof filename is "object"
      @data = new Data(filename)
    else
      return
    @filter = null
    data = @data
    firstByte = data.byteAt(0)
    if firstByte is 0xFF and data.byteAt(1) is 0xD8
      new JPEG(data)
    else if firstByte is 0x89 and data.stringAt(1, 3) is "PNG"
      new PNG(data)
    else
      throw new Error("Unknown image format.")

  pdf_image
)()
pdf_document.prototype.image = (src, x, y, options) ->
  if typeof x is "object"
    options = x
    x = null
  x = x or (if options? then options.x else undefined) or @x
  y = y or (if options? then options.y else undefined) or @y
  if @_imageRegistry[src]
    _ref = @_imageRegistry[src]
    image = _ref[0]
    obj = _ref[1]
    label = _ref[2]
  else
    image = pdf_image.open(src)
    obj = image.object(this)
    label = "I" + (++@_imageCount)
    @_imageRegistry[src] = [ image, obj, label ]
  w = (if options? then options.width else undefined) or image.width
  h = (if options? then options.height else undefined) or image.height
  if options
    if options.width and not options.height
      wp = w / image.width
      w = image.width * wp
      h = image.height * wp
    else if options.height and not options.width
      hp = h / image.height
      w = image.width * hp
      h = image.height * hp
    else if options.scale
      w = image.width * options.scale
      h = image.height * options.scale
    else if options.fit
      _ref2 = options.fit
      bw = _ref2[0]
      bh = _ref2[1]

      bp = bw / bh
      ip = image.width / image.height
      if ip > bp
        w = bw
        h = bw / ip
      else
        h = bh
        w = bh * ip
  @y += h  if @y is y
  y = @page.height - y - h
  _base[label] = obj  unless (_ref3 = (_base = @page.xobjects)[label])?
  @save()
  @addContent "" + w + " 0 0 " + h + " " + x + " " + y + " cm"
  @addContent "/" + label + " Do"
  @restore()
  this
#
#
#
#
#
#
#
#
#
#
###########################################################


















###########################################################
#
#
#
#
###

DATABASE MODELING

- set up the schemas
- they's all prefixed with mongo_

###
#
#
#
#
#
# user schema Definition
user_schema = new schema
  email: String
  #
  alerts: String
  #
  password_token: String
  password_token_generated: Date
  password_encrypted: String
  #
  role: String
  #
  name: String
  title: String
  phone: String
  company: String
  fax: String
  address: String
  address_2: String
  #
  twitter_url: String
  facebook_url: String
  linkedin_url: String
  profile_urls: [String]
  profile_image_urls: [String]
  profile_image_url: String
  #
  stripe:
    id: String
    active_card:
      cvc_check: String
      exp_month: Number
      exp_year: Number
      last4: String
      card_type: String
  card_number:
    type: Number
    default: 0
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
#
#
#
#
# user Authentication
user_schema.static 'authenticate', (email, password, next) ->
  if !email || !password || email == '' || password == ''
    next 'Please enter an email address and password'
  else
    mongo_user.findOne
      email: email
      active:true
    , (err,found_user) ->
      if err
        next 'Database Error'
      else
        if found_user
          if !found_user.password_encrypted
            next 'That email address is currently registered with a social account.<p>Please try logging in with a social network such as facebook or twitter.'
          else if compareEncrypted password, found_user.password_encrypted
            next null, found_user
          else
            next 'Password incorrect for that email address.'
        else
          next 'No account found for that email address.'
#
# Actually build the user Model we just created
mongo_user = mongoose.model 'users', user_schema
#
#
#
#
#
#
# ---------------------------------------------
# These are old and for backwards compatibility
line_schema = new schema
  order_id: Number
  color: String
  font_family: String
  text_align: String
  h: Number
  w: Number
  x: Number
  y: Number
theme_template_schema = new schema
  qr:
    color1: String
    color2: String
    color2_alpha: Number
    style: String
    h: Number
    w: Number
    x: Number
    y: Number
  lines: [line_schema]
  color1: String
  color2: String
  s3_id: String
# ---------------------------------------------
#
#
#
pattern_schema = new schema
  s3_id: String
  title: String
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
mongo_pattern = mongoose.model 'patterns', pattern_schema
#
#
#
#
#
# Style All Items
item_schema = new schema
  type: String # ['qr','line','image']
  order_id: Number
  s3_id: String
  color: String
  color_2: String
  color_2_opacity: Number
  qr_style: String
  font_family: String
  text_align: String
  side: Number # 0 for front, 1 for back
  h: Number
  w: Number
  x: Number
  y: Number
#
#
# Themes
theme_schema = new schema
  user_id: String
  items: [item_schema]
  cache: [Boolean]
  date_updated:
    type: Date
    default: Date.now
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
  #
  #
  #
  # ---------------------------------------------
  # These are old and for backwards compatibility
  theme_templates: [theme_template_schema]
  category: String
  color1: String
  color2: String
  s3_id: String
  # ---------------------------------------------

mongo_theme = mongoose.model 'themes', theme_schema
#
#
#

mongo_theme.find
  active: true
  s3_id:
    '$exists': true
, (err, themes) ->
  for theme in themes
    order_id = 0
    items = []

    # Backgrounds
    items.push
      type: 'image'
      order_id: order_id
      s3_id: theme.s3_id
      side: 0
      x: 0
      y: 0
      h: 100
      w: 100
    order_id++
    items.push
      type: 'image'
      order_id: order_id
      s3_id: theme.s3_id
      side: 1
      x: 0
      y: 0
      h: 100
      w: 100
    #

    # QR
    order_id++
    items.push
      type: 'qr'
      order_id: order_id
      side: 0
      qr_style: theme.theme_templates[0].qr.style
      x: theme.theme_templates[0].qr.x
      y: theme.theme_templates[0].qr.y
      h: theme.theme_templates[0].qr.h
      w: theme.theme_templates[0].qr.w
      color: theme.theme_templates[0].qr.color1
      color_2: theme.theme_templates[0].qr.color2
      color_2_opacity: theme.theme_templates[0].qr.color2_alpha

    # Lines
    for line in theme.theme_templates[0].lines
      order_id++
      items.push
        type: 'line'
        order_id: order_id
        side: 0
        x: line.x
        y: line.y
        h: line.h
        w: line.w
        text_align: line.text_align
        color: line.color
        font_family: line.font_family

    # Set it
    theme.items = items

    # Log
    theme.save (err) ->
      console.log err if err



#
#
# Style Field Positions
status_schema = new schema
  status: String
  user_id: String
  date_added:
    type: Date
    default: Date.now
#
#
order_schema = new schema
  order_number: String
  user_id: String
  theme_id: String
  status: String
  values: [String]
  address: String
  city: String
  coupon_code: String
  full_address: String
  latitude: String
  longitude: String
  quantity: Number # number of cards
  amount: Number # cost of order
  email: String
  url: String # url they entered for website
  phone: String # phone number they entered
  alerts: String # selected alert option
  charge:
    id: String
    paid: Boolean
    refunded: Boolean
    card:
      cvc_check: String
      exp_month: Number
      exp_year: Number
      last4: String
      type: String
  date_added:
    type: Date
    default: Date.now
  #
  # Deprecated
  active_view: Number
  status_history: [status_schema]
  shipping_method: Number
  tracking_number: String
  shipping_email: String
  confirm_email: String
  s3_id: String
  #
#
mongo_order = mongoose.model 'orders', order_schema
#
#
# Visits (for stats)
visit_schema = new schema
  url_string: String
  ip_address: String
  user_agent: String
  details:
    city: String
    state: String
    country: String
    provider: String
    lat: String
    long: String
    iso: String
  date_added:
    type: Date
    default: Date.now
#
mongo_visit = mongoose.model 'visits', visit_schema
#
#
#
url_schema = new schema
  url_string: String
  card_number: String
  last_updated:
    type: Date
    default: Date.now
  visits:
    type: Number
    default: 0
  redirect_to: String
#
#
url_group_schema = new schema
  user_id: String
  order_id: String
  redirect_to: String
  urls: [url_schema]
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
#
mongo_url_group = mongoose.model 'url_groups', url_group_schema
#
url_redirect_schema = new schema
  url_string: String
  redirect_to: String
#
mongo_url_redirect = mongoose.model 'url_redirects', url_redirect_schema
#
#
#
#
#
#
#
# END DATABASE MODELING
#
#
#
###########################################################






###########################################################
#
#
#
#
###

EVERYAUTH CONFIG

- authenticating to 3rd Party Providers

###
#
#
#
#
# Handle Good Response
#
# Set up a response handler for all of the everyauth configs we are about to use
# Every one of those everyauth guys down below will call this
# 
# This should create the user or grab it based on the auth info
#
handleGoodResponse = (session, accessToken, accessTokenSecret, user_meta) ->
  #
  #
  promise = this.Promise()
  #
  #
  #
  #
  add_user_meta_to_user = (user) ->
    #
    #
    user.profile_image_urls = [] if not user.profile_image_urls
    #
    #
    add_profile_image_url = (url) ->
      user.profile_image_urls.push url
      user.profile_image_urls = _(user.profile_image_urls).uniq()
      user.profile_image_url = url if not user.profile_image_url
    #
    #
    add_url = (url) ->
      user.profile_urls.push url
      user.profile_urls = _(user.profile_urls).uniq()
    #
    #
    # Linked In
    if user_meta.publicProfileUrl
      user.name = user_meta.firstName+' '+user_meta.lastName
      user.linkedin_url = user_meta.publicProfileUrl
      #
      add_url user.linkedin_url
      #
      add_profile_image_url user_meta.pictureUrl
      #
    #
    # Facebook
    if user_meta.link
      user.name = user_meta.name
      user.facebook_url = user_meta.link
      #
      add_url user.facebook_url
      #
    #
    # Twitter
    if user_meta.screen_name
      user.name = user_meta.name
      user.twitter_url = 'http://twitter.com/'+user_meta.screen_name
      #
      add_url user.twitter_url
      add_url user_meta.url if user_meta.url
      #
      add_profile_image_url user_meta.profile_image_url_https.replace /_normal/, ''
    #
    #
    #
    # All
    if user_meta.email
      user.email = user_meta.email
    #
    #
    user.save (err, saved_user) -> 
      if err
        log_err err
        promise.fail err
      else
        #
        promise.fulfill saved_user
        #
        redis_pub.publish 'logins', saved_user._id
  #
  #
  #
  #
  if session and session.auth and session.auth.userId
    mongo_user.findById session.auth.userId, (err, existinguser) ->
      if err
        log_err err
        promise.fail err
      else
        add_user_meta_to_user existinguser
    #
    #
  else
    #
    #
    #
    #
    userSearch = {}
    #
    if user_meta.publicProfileUrl
      userSearch.linkedin_url = user_meta.publicProfileUrl
    if user_meta.link
      userSearch.facebook_url = user_meta.link
    if user_meta.screen_name
      userSearch.twitter_url = 'http://twitter.com/'+user_meta.screen_name
    if user_meta.email
      userSearch.email = user_meta.email
    #
    mongo_user.findOne userSearch, (err,existinguser) ->
      if err
        log_err err
        promise.fail err
      else if existinguser
        add_user_meta_to_user existinguser
      else
        add_user_meta_to_user new mongo_user
    #
  promise
#
#
###
Create the Everyauth Accessing the user function
per the "Accessing the user" section of the everyauth README
###
#
#
everyauth.everymodule.findUserById (userId, callback) ->
  mongo_user.findById userId, callback
#
# Twitter API Key and Config
everyauth.twitter.consumerKey 'I4s77xbnJvV0bHa7wO8zTA'
everyauth.twitter.consumerSecret '7JjalH7ZVkExJumLIDwsc8BkgxGoaxtSlipPmChY0'
everyauth.twitter.findOrCreateUser handleGoodResponse
everyauth.twitter.redirectPath '/success'
#
# Facebook API Key / Config
everyauth.facebook.appId '292309860797409'
everyauth.facebook.appSecret '70bcb1477ede9a706e285f7faafa8e32'
everyauth.facebook.findOrCreateUser handleGoodResponse
everyauth.facebook.redirectPath '/success'
everyauth.facebook.scope 'email'
#
# LinkedIn API Key / Config
everyauth.linkedin.consumerKey 'fuj9rhx302d7'
everyauth.linkedin.consumerSecret 'pvWmN5CkrdT3GHF3'
everyauth.linkedin.findOrCreateUser handleGoodResponse
everyauth.linkedin.redirectPath '/success'
#
# Google API Key / Config
everyauth.google.appId '90634622438-pn8nk974spacthoc1joflnkqhk9hj60q.apps.googleusercontent.com'
everyauth.google.appSecret '7TOwXY-cPbbpgb6u9Y_kSfnX'
everyauth.google.findOrCreateUser handleGoodResponse
everyauth.google.scope 'https://www.googleapis.com/auth/userinfo.email'
everyauth.google.redirectPath '/success'
#
# Google API requires additional setup to use 
rest = require('./node_modules/everyauth/node_modules/restler');
everyauth.google.fetchOAuthUser (accessToken) ->
  promise = this.Promise()
  rest.get 'https://www.googleapis.com/userinfo/email', 
    query:
      oauth_token: accessToken
      alt: 'json'
  .on 'success',(data, res) ->
    oauthuser = 
      email: data.data.email
    promise.fulfill oauthuser
  .on 'error', (data, res) ->
    promise.fail data
  promise;
#
# everyauth.debug = true
#
#
# END EVERYAUTH CONFIG
#
#
#
##########################################################



http_request = require 'request'

# Variables we'll re-use
customer_questions_available = true
customer_questions_last_checked = 0

# The checking function
campfire_check = (req, res, next) ->
  try
    if customer_questions_last_checked < (new Date() - 1000*60)
      http_request 'https://9fc02ebc1276b9a8b87e0fff796d5e29d7ab61f5:X@jodesco.campfirenow.com/room/455425.json', (err, res, body) ->
        if err or res.statusCode isnt 200
          log_err err
        else
          result = JSON.parse body
          customer_questions_last_checked = new Date()
          customer_questions_available = false
          for user in result.room.users
            if user.type is 'Member'
              customer_questions_available = true
  catch err
    log_err err
  req.customer_questions_available = customer_questions_available
  next()




###########################################################
#
#
#
#
###

EXPRESS APPLICATION CONFIG

- set route defaults
- configure middleware, etc

###
#
#
#
# ## App configurations
# ### Global app settings
#
# **Note**: Notice that we got our session secret from the configuration file. In this file
# we can define our configurations as globals or based on the node environment, thus 
# keeping all the configurable variables centralized instead of being scattered all over.
app.configure ->
  app.set "views", __dirname + '/views'
  app.set "view engine", "jade"
  app.set 'view options',
    scripts: []
    env: app.settings.env
    short_domain: short_domain
    user: false
    session: false
    error_message: false
    abtest: 0
    _: _
    #
    # Cut off at 60 characters 
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    description: 'Design and create your own QR code business cards. See analytics and manage QR code links anytime in the Cardsly dashboard.'
    # H1 tag - allows html to be passed in, using brackets and all, e.g.: 
    h1: '<span>Get notified! with QR code business cards</span>'
    #
    #
  #delete express.bodyParser.parse['multipart/form-data']
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: 'how now brown cow bow wow'
    store: session_store
    cookie:
      maxAge: 86400000 * 14
  app.use express.static(__dirname + '/public')
  app.use everyauth.middleware()
  app.use require('./assets/js/libs/assets.js')()
  app.use campfire_check


# ### Environment based settings
#
# **Note**: Express defaults to 'development' environment if $NODE_ENV is not defined.
# If you wish to change to any other environment, run `export NODE_ENV='myEnv'`.
# You can define as many environments and configurations as you wish.
#
# To get the current node environment, in Express use `app.settings.env`. 
#
# For example, 
#
#     console.log(app.settings.env)
app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()
#
#
#
# END EXPRESS APP CONFIG
#
#
#
###########################################################


by_an_in = (visit) ->
  has_word = (word) -> Boolean visit.user_agent.match new RegExp(word,'i')
  visit_details =
    browser: (if has_word('chrome') then 'Chrome' else if has_word('msie') then 'IE' else if has_word('firefox') then 'Firefox' else if has_word('iphone') then 'iPhone' else if has_word('ipad') then 'iPad' else if has_word('android') then 'Android' else if has_word('safari') then 'Safari' else 'Other')+(if has_word('mobile') then ' Mobile' else '')
    location: visit.details.city+', '+visit.details.state+' '+visit.details.iso
    date_added: visit.date_added
  'by'+(if visit_details.browser.match(/^(a|e|i|o|u)/) then ' an' else '')+' '+visit_details.browser+' in '+visit_details.location+''





io = require('socket.io').listen app

maybe_log_err = (err) ->
  log_err err if err


redis_visits_sub = redis.createClient redis_options.port, redis_options.host
if redis_options.pass
  redis_visits_sub.auth redis_options.pass, maybe_log_err
redis_visits_sub.on 'error', log_err

redis_logins_sub = redis.createClient redis_options.port, redis_options.host
if redis_options.pass
  redis_logins_sub.auth redis_options.pass, maybe_log_err
redis_logins_sub.on 'error', log_err


io.configure () ->
  io.set 'transports', ['xhr-polling']
  #io.set 'store', io_store
  io.set 'log level', '2'
  io.set 'authorization', (data, next) ->
    cookies = data.headers.cookie.split /; */
    sid = false
    for cookie in cookies
      crumbles = cookie.split /\=/
      if crumbles[0] is 'connect.sid'
        sid = crumbles[1]
    session_store.get unescape(sid), (err, session) ->
      if session
        data.session = session
        data.sid = sid
        next null, true
      else
        next null, false
#
#
#
#
redis_logins_sub.subscribe 'logins'
#
#
redis_visits_sub.subscribe 'visits'
#
#
io_visits = io.of('/visits').on 'connection', (socket) ->
  hs = socket.handshake
  if hs.session
    socket.on 'subscribe_to', (params) ->
      #
      # The function used either way
      show_visits = (err, visits) ->
        #
        parsed_visits = _(visits).map (visit) ->
          by_an_in: by_an_in visit
          date_added: visit.date_added
        #
        #
        socket.emit 'load_visits', parsed_visits.reverse()

      #
      #
      # On each update find 1
      redis_visits_sub.on 'message', (pattern, key) ->
        if params.search_string is key
          console.log 'FOUND: ', params.search_string
          mongo_visit.find
            url_string: params.search_string
          ,[],
            limit: 1
            sort:
              date_added: -1
          , show_visits
      #
      # And always on load find 3
      mongo_visit.find
        url_string: params.search_string
      ,[],
        limit: 3
        sort:
          date_added: -1
      , show_visits




mongo_url_redirect.findOne
  url_string: 'loghome'
, (err, url_redirect) ->
  if not url_redirect
    url_redirect = new mongo_url_redirect
  url_redirect.redirect_to = '/alerts'
  url_redirect.url_string = 'loghome'
  url_redirect.save (err) ->
    log_err err if err














###########################################################
#
#
#
#
###

POST ROUTES

- for AJAX stuff mostly
- maybe other post actions

###
#
#
#
# Post Helper Functions
#
#
#
#
#
#
# Syllable generation
#
# - based on http://en.wikipedia.org/wiki/Letter_frequency
# - my math shows the current incarnation to generate about 456192000 different possibilities - good enough for now?
#
mrg = require(__dirname + '/assets/js/libs/mrg')
valid_url_characters = []
pre_vowels = [
  ['e',12]
  ['ee',8]
  ['ea',8]
  ['a',8]
  ['o',7]
  ['oo',7]
  ['oa',7]
  ['oi',7]
  ['i',7]
  ['u',3]
  ['y',2]
]
pre_hard_consonants = [
  ['t',9]
  ['n',7]
  ['s',6]
  ['h',6]
  ['r',5]
  ['d',4]
  ['l',4]
  ['c',3]
  ['m',2]
  ['w',2]
  ['f',2]
  ['g',2]
  ['p',2]
  ['b',2]
  ['k',1]
  ['j',1]
  ['qu',1]
  ['z',1]
]
pre_consonants = [
  ['t',9]
  ['n',7]
  ['s',6]
  ['h',6]
  ['r',5]
  ['d',4]
  ['l',4]
  ['c',3]
  ['ck',3]
  ['m',2]
  ['w',2]
  ['f',2]
  ['g',2]
  ['y',2]
  ['p',2]
  ['b',2]
  ['k',1]
  ['j',1]
  ['x',1]
  ['z',1]
]
vowels = []
for l in pre_vowels
  for i in [1..l[1]]
    vowels.push l[0]
consonants = []
for l in pre_consonants
  for i in [1..l[1]]
    consonants.push l[0]
hard_consonants = []
for l in pre_hard_consonants
  for i in [1..l[1]]
    hard_consonants.push l[0]
numbers = ['',0,1,2,3,4,5,6,7,8,9]
random_url = () ->
  psuedo = ''
  h_c_l = hard_consonants.length - 1
  c_l = consonants.length - 1
  v_l = vowels.length - 1
  n_l = numbers.length - 1
  add_number = ->
    for i in [0..1]
      psuedo += numbers[Math.round(mrg.generate_real()*n_l)]
    if Math.round(mrg.generate_real())
      psuedo += 0
  add_vowel = ->
    for i in [0..0]
      vowel = vowels[Math.round(mrg.generate_real()*v_l)]
      psuedo += vowel
  add_consonant = ->
    for i in [0..0]
      psuedo += consonants[Math.round(mrg.generate_real()*c_l)]
  add_hard_consonant = ->
    for i in [0..0]
      psuedo += hard_consonants[Math.round(mrg.generate_real()*h_c_l)]
  add_hard_consonant()
  add_vowel()
  add_consonant()
  add_vowel()
  add_consonant()
  add_number()
  psuedo
#
#
#
###

USAGE

create_url 'http://url-I-want-to-redirect-to.com', (err, new_url) ->
  console.log 'Now http://cards.ly/' + new_url.url_string + ' will redirect there.'

###
create_url = (redirect_to, next) ->
  try_url = random_url()
  mongo_url_redirect.count
    url_string: try_url
  , (err, count) ->
    if err
      next err
    else if count
      create_url next
    else
      new_url = new mongo_url_redirect
      new_url.redirect_to = redirect_to
      new_url.url_string = try_url
      new_url.save (err, saved_url) ->
        if err
          next err
        else
          next null, saved_url
#
#
#
###

USAGE

create_urls
  redirect_to: 'http://url-I-want-to-redirect-to.com'
  volume: 100
, (err, new_urls) ->
  for new_url in new_urls
    console.log 'Now http://cards.ly/' + new_url.url_string + ' will redirect there.'

###
create_urls = (options, next) ->
  console.log 'CREATE OPTIONS: ', options
  if typeof(options) isnt 'object'
    next 'No Options Sent'
  else if not options.redirect_to
    next 'Please set redirect_to'
  else if not options.volume
    next 'Please set volume'
  else
    #
    new_urls = []
    #
    check_if_done = ->
      if new_urls.length is options.volume
        next null, new_urls
    #
    for i in [1..options.volume]
      create_url options.redirect_to, (err, new_url) ->
        if err
          next err
        else
          new_urls.push new_url
          check_if_done()
#
#
#
#
#
# Generic Ajax Error Handling
check_no_err_ajax = (err, res) ->
  if err
    log_err err
    res.send
      err: err
  !err
#
#
#
#
#
#
#
#
#
hex_to_rgba = (h) ->
  cut_hex = (h) -> if h.charAt(0)=="#" then h.substring(1,7) else h
  hex = cut_hex h
  r = parseInt hex.substring(0,2), 16
  g = parseInt hex.substring(2,4), 16
  b = parseInt hex.substring(4,6), 16
  a = hex.substring(6,8)
  if a
    a = (parseInt a, 16) / 255
  else
    a = 1
  if a is 1
    'rgb('+r+','+g+','+b+')'
  else
    'rgba('+r+','+g+','+b+','+a+')'
#
#
#
save_session = (o) ->
  #
  # Default it Out First
  if not o.req.session.order_form
    o.req.session.order_form = {}
  #
  # Then loop through and add all values
  for new_key,new_value of o.new_values
    o.req.session.order_form[new_key] = new_value
  #
  #
#
#
app.post '/save-order', (req, res) ->
  #
  req.session.order = req.body
  #
  if req.user
    req.user.email = req.session.order.email
    req.user.phone = req.session.order.phone
    req.user.alerts = req.session.order.phone
    #
    req.user.save (err, saved_user) ->
      log_err err if err
      #
      #
      console.log saved_user
  #
  res.send
    success: true
  #
#
#
#
#
# AJAX request for saving theme
app.post '/save-theme', (req, res) ->
  #
  theme = req.body
  #
  #
  # If we're updating do this
  if theme._id
    mongo_theme.findById theme._id, (err, found_theme) ->
      if check_no_err_ajax err, res
        found_theme.date_updated = new Date()
        if typeof(theme.active) is 'boolean'
          found_theme.active = theme.active
        #
        # Push the new template in
        found_theme.items = theme.items
        #
        found_theme.cache = null
        #
        #
        found_theme.save (err,theme_saved) ->
          if check_no_err_ajax err, res
            res.send
              success: true
              theme: theme_saved
  #
  #
  #
  # This indicates we are creating a new one, nothing to update
  else
    #
    #
    #
    new_theme = new mongo_theme
    if typeof(theme.active) is 'boolean'
      new_theme.active = theme.active
    # Push the new template in
    new_theme.items = theme.items
    #
    new_theme.user_id = req.sessionID
    if req.user and req.user._id
      new_theme.user_id = req.user._id
    #
    #
    #
    #
    #
    #
    new_theme.save (err,theme_saved) ->
      if check_no_err_ajax err, res
        res.send
          success: true
          theme: theme_saved
#
#
#
#
#
#
#
#
app.post '/search-address', (req, res) ->
  #
  #
  #
  #
  geo.geocoder geo.google, req.body.street+' '+req.body.zip_code, false, (full_address, latitude, longitude, details) ->
    #
    req.session.order = {} if not req.session.order
    #
    #
    req.session.order.address = req.body.street
    req.session.order.city = req.body.zip_code
    req.session.order.full_address = full_address
    req.session.order.latitude = latitude
    req.session.order.longitude = longitude
    #
    res.send req.session.order
    #
    #
#
#
#
#
# ----------
# Themes
# -----------------------------------
app.post '/get-themes', (req, res) ->
  #
  user_to_find = null
  #
  if req.user and req.user._id
    user_to_find = 
      $in: [null,req.user._id]
  else if req.sessionID
    user_to_find = 
      $in: [null,req.sessionID]
  #
  #
  mongo_theme.find
    active: true
    user_id: user_to_find
  , (err, themes) ->
    if check_no_err_ajax err, res
      themes = _(themes).sortBy (theme) ->
        if theme.user_id then '0' else theme.category + theme.date_added
      themes.reverse()
      res.send
        themes: themes
#
#
app.post '/get-theme', (req, res) ->
  #
  mongo_theme.findById req.body.theme_id, (err, theme) ->
    if check_no_err_ajax err, res
      res.send
        theme: theme
#
#
#
# Form request for multipart form uploading image
app.post '/up', (req, res) ->
  #
  #
  #
  # Set up our failure function
  s3_fail = (err) ->
    log_err err
    res.send '<script>parent.window.$.s3_result(false);</script>'
  #
  #
  # Find the file we just created
  path = req.files.image.path
  #
  #
  # Identify it's filname
  #
  #
  s3_id = random_url()+random_url()+random_url()+'.png'
  #
  #console.log path
  #
  # Resize it with ImageMagick
  im.convert [
    path
    '-resize','1050x600'
    'png:-'
  ], (err, rawImg, stderr) ->
    if err
      s3_fail err
    else
      #
      #console.log 3
      #
      buff = new Buffer rawImg, 'binary'
      img = new node_canvas.Image
      img.src = buff
      #
      #
      #console.log img.width, img.height
      #
      #
      #
      save_image_to = (width, height, dir) ->
          #
          #
          #
          #
          potential_width = img.width * height / img.height
          potential_height = height
          #
          if potential_width > width
            #
            potential_width = width
            potential_height = img.height * width / img.width
          #
          #
          canvas = new node_canvas(potential_width,potential_height)
          ctx = canvas.getContext '2d'
          ctx.drawImage img, 0, 0, potential_width, potential_height
          #
          #
          canvas.toBuffer (err, canvas_buff) ->
            log_err err if err
            #
            # Send that new file to Amazon to be saved!
            knoxReq = knoxClient.put '/'+dir+'/'+s3_id,
              'Content-Length': canvas_buff.length
              'Content-Type' : 'image/png'
            knoxReq.on 'response', (awsRes) ->
              if awsRes.statusCode != 200
                s3_fail awsRes
              if width is 525
                res.send '<script>parent.window.$.s3_result({s3_id:\''+s3_id+'\',width:'+img.width+',height:'+img.height+'});</script>'
            knoxReq.end canvas_buff
      #
      save_image_to 158, 90, '158x90'
      save_image_to 525, 300, '525x300'
      save_image_to 1050, 600, 'raw'
      #
#
#
#
#
#
#
#
# Get Session
app.post '/get-session', (req, res, next) ->
  res.send
    session: req.session
#
#
#
# Get User
app.post '/get-user', (req,res,next) ->
  #console.log 'USER: ', req.user
  if req.user
    if req.user.stripe
      req.user.stripe.id = undefined
    req.user.encrypted_password = undefined
    res.send
      user: req.user
  else
    res.send
      err: 'Not Logged In'

#
#
#
#
#
#
add_urls_to_order = (order, user, res, passed_volume) ->
  #
  #
  #
  redirect_to = order.url
  #
  # Generate order urls, based on "quantity" (which isnt really quantity)
  #
  console.log 'REDIRECT TO: ', redirect_to
  #
  #
  volume = order.quantity
  #
  #
  volume = passed_volume*1 if passed_volume
  #
  console.log 'VOLUME: ', volume
  #
  create_urls
    redirect_to: redirect_to
    volume: volume
  , (err, new_urls) ->
    #
    console.log 'CREATED URLS: ', new_urls.length
    #
    #
    mongo_url_group.findOne
      order_id: order._id
    , (err, found_url_group) ->
      #
      #
      if found_url_group
        #
        url_group = found_url_group
        #
        console.log 'FOUND GROUP OF LENGTH: ', url_group.urls.length
        #
      else
        #
        url_group = new mongo_url_group
        url_group.order_id = order._id
        url_group.user_id = user._id
        url_group.redirect_to = redirect_to
        url_group.urls = []
        #
        #
        console.log 'CREATED NEW GROUP'
      #
      #
      #
      for new_url in new_urls
        user.card_number++
        url_group.urls.push
          url_string: new_url.url_string
          redirect_to: redirect_to
          card_number: user.card_number
      #
      #
      url_group.save (err, saved_group) ->
        if err
          log_err err
        else
          #
          # This is where we kick off the processing of the pdf
          process_pdf order._id
      #
      #
      user.save (err, saved_user) ->
        if err
          log_err err
    #
    #
  volume
  #
  #
#
#
#
render_urls_to_doc = (urls, theme_template, line_copy, s3_id, next) ->
  #
  #
  # We're going to grab the background image via an http request to amazon
  #
  # Set blank imagedata
  imagedata = ''
  #
  # Hit Amazon
  request = http.get
    host: 'd3eo3eito2cquu.cloudfront.net'
    port: 80
    path: '/raw/'+s3_id
  , (response) ->
      #
      #
      dpi = 300
      #
      #
      height = 2*dpi
      width = 3.5*dpi
      #
      response.setEncoding 'binary'
      #
      response.on 'data', (chunk) ->
        imagedata += chunk
      response.on 'end', ->
        #
        # If we found the image on amazon
        if response.statusCode is 200
          # 
          s3_bg_buff = new Buffer imagedata, 'binary'
          #
          canvas = new node_canvas(width,height)
          ctx = canvas.getContext '2d'
          #
          #
          img = new node_canvas.Image
          img.src = s3_bg_buff
          ctx.drawImage img, 0, 0, width, height
          #
          #
          for line,i in theme_template.lines
            h = Math.round(line.h/100*height)
            x = line.x/100*width
            y = line.y/100*height
            w = line.w/100*width
            ctx.fillStyle = hex_to_rgba line.color
            ctx.font = h + 'px "' + line.font_family + '"'
            this_line_copy = line_copy[i].replace(/&nbsp;/g, ' ').replace(/\n/g, '')
            if line.text_align is 'left'
              ctx.fillText this_line_copy, x, y+h
            else
              measure = ctx.measureText this_line_copy, x, y+h
              if line.text_align is 'right'
                ctx.fillText this_line_copy, x+w-measure.width, y+h
              if line.text_align is 'center'
                ctx.fillText this_line_copy, x+(w-measure.width)/2, y+h
            #
          #
          canvas.toBuffer (err, bg_buff) ->
            #
            #
            #
            #
            #
            #
            #
            alpha = Math.round(theme_template.qr.color2_alpha * 255).toString 16
            #
            # Set up the PDF Document
            doc = new pdf_document()
            #
            #
            #
            pdf_dpi = 72
            #
            url_i = 0
            page = 0
            c = 0
            r = 0
            url_i_limit = urls.length
            page_limit = 1
            c_limit = 2
            r_limit = 5
            #
            qr_left = theme_template.qr.x/100*pdf_dpi*3.5
            qr_top = theme_template.qr.y/100*pdf_dpi*2
            qr_width = theme_template.qr.w/100*pdf_dpi*3.5
            qr_height = theme_template.qr.h/100*pdf_dpi*2
            # 
            #
            #
            #
            #
            next_card = ->
              #
              #
              #
              #
              if url_i is url_i_limit
                next doc
              else
                c = 0 if c is c_limit
                r = 0 if r is r_limit
                if page is page_limit
                  page = 0  
                  doc.addPage()
                #
                #
                card_width = 3.5*pdf_dpi
                card_height = 2*pdf_dpi
                #
                width_x_height =
                  width: card_width
                  height: card_height
                #
                left = c*card_width + .75*pdf_dpi
                top = r*card_height + .5*pdf_dpi
                #
                #
                #
                qr_canvas = qr_code.draw_qr
                  node_canvas: node_canvas
                  style: 'round'
                  url: short_domain+urls[url_i].url_string
                  card_number: urls[url_i].card_number
                  hex: theme_template.qr.color1
                  hex_2: theme_template.qr.color2+alpha
                #
                #
                #
                qr_canvas.toBuffer (err, qr_buff) ->
                  #
                  #
                  #
                  # Start with it's base background
                  doc.image bg_buff, left, top, width_x_height
                  #
                  # Top Left Row Expand
                  doc.image s3_bg_buff, left-card_width, top-card_height, width_x_height if r is 0 and c is 0
                  #
                  # Top Row Expand
                  doc.image s3_bg_buff, left, top-card_height, width_x_height if r is 0
                  #
                  # Top Right Row Expand
                  doc.image s3_bg_buff, left+card_width, top-card_height, width_x_height if r is 0 and c is c_limit-1
                  #
                  # Bottom Row Expand
                  doc.image s3_bg_buff, left, top+card_height, width_x_height if r is r_limit-1
                  #
                  # Left Column Expand
                  doc.image s3_bg_buff, left-card_width, top, width_x_height if c is 0
                  #
                  # Bottom Left Row Expand
                  doc.image s3_bg_buff, left-card_width, top+card_height, width_x_height if r is r_limit-1 and c is 0
                  #
                  # Right Column Expand
                  doc.image s3_bg_buff, left+card_width, top, width_x_height if c is c_limit-1
                  #
                  # Bottom Right Row Expand
                  doc.image s3_bg_buff, left+card_width, top+card_height, width_x_height if r is r_limit-1 and c is c_limit-1
                  #
                  #
                  #
                  #
                  #
                  #
                  doc.image qr_buff, left+qr_left, top+qr_top,
                    width: qr_width
                    height: qr_height
                  #
                  #
                  url_i++
                  #
                  #
                  # Delay Quarter of Second
                  setTimeout ->
                    next_card()
                  , 100
                  #
                  #
                  #
                  r++
                  c++ if r is r_limit
                  page++ if r is r_limit and c is c_limit
            #
            #
            next_card()
            #
#
#
process_pdf = (order_id) ->
  #
  #
  console.log 'ORDERID:', order_id
  #
  # Find the Order that's passed in
  mongo_order.findById order_id, (err, order) ->
    #
    #
    console.log 'ORDER FOUND:', order._id
    #
    #
    # Find the theme for that order
    mongo_theme.findById order.theme_id, (err, theme) ->
      #
      console.log 'THEME FOUND:', theme._id
      #
      # Find the urls we're going to use
      mongo_url_group.findOne
        order_id: order._id
      , (err, url_group) ->
        #
        console.log 'GROUP FOUND:', url_group._id
        #
        if err
          log_err err
        else
          #
          #
          # The theme_template used based on the view from the order
          theme_template = theme.theme_templates[order.active_view]
          #
          #
          # Set up the finalize function for later
          render_urls_to_doc url_group.urls, theme_template, order.values, theme.s3_id, (doc) ->
            #
            # FINALLY - Save it to Amazon
            #
            s3_id = order_id + '_' + random_url()
            knox_buff = new Buffer doc.output(), 'binary'
            #
            knoxReq = knoxClient.put '/pdfs/'+s3_id+'.pdf',
              'Content-Length': knox_buff.length
              'Content-Type' : 'application/pdf'
            knoxReq.on 'response', (res) ->
              if res.statusCode != 200
                console.log 'ERR', res
              else
                #
                # And update the database with the s3 id found.
                order.s3_id = s3_id
                order.save (err, saved_order) ->
                  log_err err if err
                #
            knoxReq.end knox_buff
            console.log 'ALL DONE'
          #
          #
          #console.log
#
#
#
if app.settings.env is 'development'
  # Test
  stripe = require('./assets/js/libs/stripe.js') 'VGZ3wGSA2ygExWhd6J9pjkhSD5uqlE7u'
else
  # Production
  stripe = require('./assets/js/libs/stripe.js') 'SXiUQj37CG6bszZQrkxKZVmQI7bZgLpW'
#
#
app.post '/validate-coupon', (req, res, next) ->
  #
  apply_discount = (discount) ->
    #
    req.session.order = {} if not req.session.order
    #
    req.session.order.coupon_code req.body.coupon_code
    #
    res.send
      discount: discount
  #
  #
  #
  #
  # For customer number one
  if req.body.coupon_code and req.body.coupon_code is 'ferdur120'
    apply_discount 10
  #
  # For us
  else if req.body.coupon_code and req.body.coupon_code is 'forusonly'
    apply_discount 10
  #
  else
    #
    #
    #
    ###
    TODO
    
    - SAVE THEIR INFO HERE

    ###
    #
    #
    #
    res.send
      error: 'Discount code not found.'
    ###
    res.send
      error: 'Im sorry this page isnt active yet'
    ###
#
req_session_order_is_fulfilled = (req) ->
  #
  if not req.session.order
    res.send
      error: 'Please design your card'
  else if not req.session.order.email
    res.send
      error: 'Please enter an e-mail address'
  else if not req.session.order.full_address
    res.send
      error: 'Please enter a shipping address'
  else if not req.session.order.url
    res.send
      error: 'Please enter a url'
  else
    #
    return true
#
#
app.post '/validate-purchase', (req, res, next) ->
  #
  #
  if req_session_order_is_fulfilled req
    #
    ###
    TODO
    
    - SAVE THEIR INFO HERE

    ###
    #
    #
    #
    res.send
      success: true
    ###
    res.send
      error: 'Im sorry this page isnt active yet'
    ###
#
app.post '/set-password', (req, res, next) ->
  if req.user
    #
    if req.user.password_token_generated < new Date(new Date()-1000*60*60*24)
      res.send
        err: 'Token Expired.'
    else
      #
      req.user.password_encrypted = encrypted(req.body.password);
      req.user.save (err, user_saved) ->
        if err
          log_err err
      #
      res.send
        success: true
  else
    res.send
      err: 'Not logged in.'
#
app.post '/send-password', (req, res, next) ->
  #
  mongo_user.findOne
    email: req.body.email
  , (err, found_user) ->
    if check_no_err_ajax err, res
      #
      if found_user
        #
        generate_password_token found_user
        #
        res.send
          success: true
      else
        #
        res.send
          err: 'No user found for that e-mail address.'
#
generate_password_token = (for_user) ->
  #
  characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split ''
  n_l = characters.length-1
  #
  psuedo = ''
  for i in [0..15]
    psuedo += characters[Math.round(mrg.generate_real()*n_l)]
  #
  #
  for_user.password_token = psuedo
  for_user.password_token_generated = new Date()
  #
  for_user.save (err, saved_user) -> 
    log_err err if err
  #
  #
  password_link = short_domain + 'set-password/' + psuedo
  #
  #
  # Send the user an email
  nodemailer.send_mail
    sender: 'help@cards.ly'
    to: for_user.email
    subject: 'Cardsly password link'
    html: '<p>Please use this link to login to cardsly and set your password:</p><p><a href="'+password_link+'">'+password_link+'</a></p><p>This link will expire in 24 hours.</p>'
  , (err, data) ->
    if err
      log_err err
#
#
app.post '/confirm-purchase', (req, res, next) ->
  #
  #
  if req_session_order_is_fulfilled req
    #
    # If we're logged in
    if req.user
      next()
    #
    # Otherwise, we need to make it based on their email address
    else
      # Create a user
      user = new mongo_user
      user.email = req.session.order.email
      user.phone = req.session.order.phone
      user.alerts = req.session.order.alerts
      #
      #
      user.save (err, saved_user) ->
        if check_no_err_ajax err, res
          #
          # Generate an email with a login link
          generate_password_token saved_user
          #
          #
          # Log that user in
          req.user = saved_user
          #
          req.session.auth = 
            userId: saved_user._id
          #
          #
          mongo_theme.find
            active: true
            user_id: req.sessionID
          , (err, themes) ->
            if not err
              for theme in themes
                theme.user_id = user._id
                console.log theme
                theme.save()
          #
          # Then pass them forward
          next()
, (req, res, next) ->
  #
  #
  order = new mongo_order
  order.user_id = req.user._id
  order.theme_id = req.session.order.active_theme_id
  order.status = 'Pending'
  #
  order.quantity = req.session.order.quantity
  order.values = req.session.order.values
  #
  order.address = req.session.order.address
  order.city = req.session.order.city
  order.full_address = req.session.order.full_address
  #
  order.coupon_code = req.session.order.coupon_code
  order.amount = req.session.order.amount * 1
  #
  order.email = req.session.order.email
  order.phone = req.session.order.phone
  order.url = req.session.order.url
  #
  #
  #
  order.save (err, new_order) ->
    if check_no_err_ajax err, res
      req.order = new_order
      #
      #
      # If they passed in a token, create a customer
      if req.body.token
        stripe.customers.create
          card: req.body.token
          email: req.order.email or null
          description: ''+req.order._id
        , (err, customer) ->
          if err
            log_err err
            res.send
              err: customer.error.message
          else
            #
            #console.log 'CUSTOMER: ', customer
            #
            # Save the payment token to the user
            req.user.stripe = customer
            req.user.stripe.active_card.card_type = customer.active_card.type
            #console.log req.user.stripe
            req.user.save (err, user_saved) ->
              if err
                log_err err
            #
            #
            next()
      #
      #
      #
      # Otherwise, make sure they have an existing stripe
      else if req.user.stripe and req.user.stripe.active_card and req.user.stripe.id
        next()
      #
      #
      #
      # Otherwise, we got problems
      else
        res.send
          err: 'No Payment Data Received'
      #
      #
, (req, res, next) ->
  #
  new_order = req.order
  #
  to_charge_amount = new_order.amount*100
  #
  #console.log to_charge_amount
  #
  # Attempt a charge
  stripe.charges.create
    currency: 'usd'
    amount: to_charge_amount
    customer: req.user.stripe.id
    description: ''+req.order._id
  , (err, charge) ->
    #
    #
    #console.log 'CHARGE: ', charge
    #
    #
    #
    # Save the order's url
    #
    #  - This is used to show the "contact page" for an order
    #
    create_url 'http://cards.ly/order/'+new_order._id, (err, order_url) ->
      if check_no_err_ajax err, res
        #
        #
        # Save that url to the order
        new_order.order_number = order_url.url_string
        #
        #
        # Save the charge result to the order
        new_order.charge = charge
        #
        #
        new_order.save (err, final_order) ->
          if err
            log_err err
        #
        #
        #
        if err
          log_err err
          res.send
            err: charge.error.message
        else if !charge.paid and to_charge_amount isnt 0
          console.log 'ERR: stripe charge resulted in not paid for some reason.'
          res.send
            err: 'Charge resulted in not paid for some reason.'
        else
          if to_charge_amount is 0
            charge.paid = true
          res.send
            order_id: new_order._id
            charge: charge
          #
          #
          ################################
          # Do Cleanup and send emails etc
          ################################
          #
          #
          # Generate the Urls
          volume = add_urls_to_order new_order, req.user
          #
          #
          #
          #
          ############
          # Send Email
          ############
          #
          # Send Confirmation Email
          #####
          #
          # Prep the Email Message
          #
          total_paid = to_charge_amount/100
          #
          message = '<p>' + (req.user.name or req.user.email) + ',</p><p>We\'ve received your order and are processing it now.</p><p>Here are the details of your order: </p> <p><b>Order ID: </b>'+new_order.order_number+'</p></p> <p><b>Amount of Cards: </b>'+new_order.quantity+'</p></p> <p><b>Total Paid: </b>$'+total_paid+'</p><p> Please don\'t hesitate to let us know if you have any questions at any time. <p>Reply to this email, call us at 480.428.8000, or reach <a href="http://twitter.com/cardsly">us</a> on <a href="http://facebook.com/cardsly">any</a> <a href="https://plus.google.com/101327189030192478503/posts">social network</a>. </p>'
          #
          # Send the user an email
          if new_order.email
            nodemailer.send_mail
              sender: 'help@cards.ly'
              to: new_order.email
              subject: 'Cardsly Order Confirmation - Order ID: ' + new_order.order_number
              html: message
            , (err, data) ->
              if err
                log_err err
          #
          # Send us an email
          nodemailer.send_mail
            sender: 'support@cards.ly'
            to: 'help@cards.ly'
            subject: 'Cardsly Order Received - Order ID: ' + new_order.order_number
            html: '<p>A new order was received!</p><blockquote>' + message + '</blockquote>'
          , (err, data) ->
            if err
              log_err err
#
#
#
#
#
#
#
#
#
#
#
#
# Normal Login
app.post '/login', (req, res, next) ->
  mongo_user.authenticate req.body.email, req.body.password, (err, user) ->
    if err || !user
      res.send
        err: err
    else
      req.session.auth = 
        userId: user._id
      res.send
        success: true
      #
      #
      #
      if req.sessionID
        #
        #
        mongo_theme.find
          active: true
          user_id: req.sessionID
        , (err, themes) ->
          if not err
            for theme in themes
              theme.user_id = user._id
              console.log theme
              theme.save()
#
#
#
#
#
#
# END POST ROUTES
#
#
#
###########################################################























###########################################################
#
#
#
#
###

GET ROUTES

- normal pages
- anything that's a regular page

USAGE

app.get '/path-you-want', (req, res, next) ->
  do = 'something'
  req.result = do
  next()
, (req, res, next) ->
  res.render 'path_you_want'
    req: req

###
#
#
#
# Get page helper functions
secured_page_admin = (req, res, next) ->
  if req.user && req.user.role == 'admin'
    next()
  else
    res.send '',
      Location: '/cards'
    ,302
secured_page = (req, res, next) ->
  if req.user
    next()
  else
    res.send '',
      Location: '/'
    ,302
check_no_err = (err, res) ->
  if err
    log_err err
    res.send '',
      Location: '/error'
    ,302
  !err
#
#
#
app.get '/[A-Za-z0-9]{5,}/?$', (req, res, next) ->
  #
  #
  if !req or !req.url
    next()
  else
    #
    # Prep the string to search for
    search_string = req.url.replace /[^a-z0-9]/ig, ''
    #
    #
    #
    mongo_url_redirect.find
      url_string: search_string
    , (err, url_redirects) ->
      if err
        log_err err
        next()
      else if not url_redirects.length
        next()
      else
        #
        # Go ahead and redirect them now
        res.send '',
          'Location' : url_redirects[0].redirect_to
        , 302
        #
        #
        #
        #
        ip = req.socket.remoteAddress
        if req.headers['x-real-ip']
          ip = req.headers['x-real-ip']
        if ip.match /(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
          ip = '72.222.222.120'

        
        http_request 'http://api.geoio.com/q.php?key=CFyhyWQCmB9ZukG8&qt=geoip&d=pipe&q='+ip, (err, response, body) ->
          if err or response.statusCode isnt 200
            log_err err
          else
            result = body.split /\|/
            #
            #
            visit = new mongo_visit
            visit.url_string = search_string
            visit.ip_address = ip
            visit.user_agent = req.headers['user-agent']
            visit.details =
              city: result[0]
              state: result[1]
              country: result[2]
              provider: result[3]
              lat: result[4]
              long: result[5]
              iso: result[6]
            visit.save (err, saved_visit) ->
              log_err err if err
            #
            #
            #
            #
            redis_pub.publish 'visits', search_string
            #
            #
            #
            # And in the mean time ...
            # Let's log a hit
            mongo_url_group.find
              'urls.url_string': search_string
            , (err, url_groups) ->
              if err
                log_err err
              else if not url_groups.length
                console.log 'ERR: redirect was found - URL_GROUP WAS NOT'
              else
                url_group = url_groups[0]
                found_url = null
                for url in url_group.urls
                  if url.url_string is search_string
                    if not url.visits
                      url.visits = 0
                    url.visits++
                    url.last_updated = new Date()
                    found_url = url
                url_group.save (err, saved_url_group) ->
                  log_err err if err
                #
                #
                #
                #
                if found_url
                  #
                  console.log url_group.user_id
                  #
                  # Find the user to send them an email
                  mongo_user.findById url_group.user_id, (err, found_user) ->
                    #
                    console.log found_user.email
                    #
                    if found_user.email
                      #
                      #
                      ordinal = (in_number) ->
                        decimal = in_number %10
                        suffix = 'th'
                        suffix = 'st' if decimal is 1
                        suffix = 'nd' if decimal is 2
                        suffix = 'rd' if decimal is 3
                        in_number+suffix
                      #
                      #
                      # Send it!
                      nodemailer.send_mail
                        sender: '"Cards.ly" <help@cards.ly>'
                        to: found_user.email
                        subject: 'Card #'+found_url.card_number+' was just scanned!'
                        html: '<p>Card #'+found_url.card_number+' was just scanned for the '+ordinal(found_url.visits)+' time '+by_an_in(visit)+'.</p><p>Check out your full dashboard at <a href="http://cards.ly">cards.ly</a></p>'
                      , (err, data) ->
                        if err
                          log_err err
                      #
                      #
                      #
                      ###
                      TODO 
                      client.sendSms '4847722735', '4805445590', 'TESTING MOFO'
                      ###
#
#
#
default_line_copy = [
  'Harold Crick'
  '123 Fiction St'
  'Phoenix, AZ 85204'
  '555-555-5545'
  'email@gmail.com'
  '@numberman'
  ''
  ''
  ''
  ''
]
#
#
#
#
#
# SSL Redirect
if app.settings.env is 'production'
  app.get '*', (req,res,next) ->
    headers = req.headers
    if headers['x-real-ip'] and headers['x-forwarded-proto'] isnt 'https'
      res.send '',
        Location: 'https://www.cards.ly'+req.url
      , 302
    else
      next()
#
#
#
#
app.get '/settings', secured_page,  (req, res, next) ->
  res.render 'settings',
    req: req
#
#
#
#
app.get '/set-password/:password_token?', (req, res, next) ->
  if req.params.password_token
    mongo_user.findOne
      password_token: req.params.password_token
    , (err, found_user) ->
      if check_no_err err
        if not found_user
          res.send '',
            Location: '/settings'
          , 302
        else
          err = null
          if found_user.password_token_generated < new Date(new Date()-1000*60*60*24)
            generate_password_token found_user
            err = '<p>Our apologies, that token has expired.</p><p>We have sent a new one. Please check your inbox.</p>'
          else
            req.user = found_user
            #
            req.session.auth = 
              userId: found_user._id

          res.render 'set_password',
            req: req
            err: err
  else
    res.send '',
      Location: '/settings'
    , 302
#
#
#
# Success Page
#
# Where they land after authenticating
# This should close automatically or redirect to the home page if no caller
app.get '/success', (req, res) ->
  res.cookie 'success_login', true
  res.send '<script>window.onload = function(){window.close();}</script>',
    'Content-Type': 'text/html'
  , 200
#
#
#
#
app.get '/add-urls-to-order/:volume/:order_id', (req, res, next) ->
  #
  #
  #
  console.log 'ADD URLS HIT FOR ', req.params.order_id
  # Find the Order that's passed in
  mongo_order.findById req.params.order_id, (err, order) ->
    if check_no_err err
      mongo_user.findById order.user_id, (err, found_user) ->
        if check_no_err err
          add_urls_to_order order, found_user, res, req.params.volume
          res.send
            'success': true
#
#
#
app.get '/re-process-pdf/:order_id', (req, res, next) ->
  #
  #
  # This is where we kick off the processing of the pdf
  process_pdf req.params.order_id
  #
  console.log 'REPROCESS HIT FOR ', req.params.order_id
  # Find the Order that's passed in
  mongo_order.findById req.params.order_id, (err, order) ->
    if check_no_err err
      order.date_added = new Date()
      order.save (err, saved_order) ->
        if check_no_err err
          #
          res.send '',
            Location: '/orders'
          , 302
#
#
render_image = (o) ->
  #
  o.side = 0 unless o.side
  #
  mongo_theme.findById o.theme_id, (err, theme) ->
    #
    imagedata = ''
    #
    if o.thumb_cache and theme.cache and ((theme.cache[0] and o.side is 0) or (theme.cache[1] and o.side is 1))
      #
      #
      o.res.send '',
        Location: '//d3eo3eito2cquu.cloudfront.net/thumb_cache/'+o.side+'/'+theme._id
      , 302
      #
      #
    else
      #
      #
      #
      canvas = new node_canvas(o.width,o.height)
      ctx = canvas.getContext '2d'
      #
      need_to_wait_on = 0
      #
      check_if_done = ->
        #
        if need_to_wait_on is 0
          #
          #
          for item, i in theme.items
            do (item) ->
              if item.side*1 is o.side*1
                h = Math.round(item.h/100*o.height)
                x = item.x/100*o.width
                y = item.y/100*o.height
                w = item.w/100*o.width
                #
                if item.type is 'image'
                  #
                  #
                  if item.s3_id
                    #
                    ctx.drawImage item.img, item.x/100*o.width,item.y/100*o.height, item.w/100*o.width, item.h/100*o.height
          #
          for item, i in theme.items
            do (item) ->
              if item.side*1 is o.side*1
                h = Math.round(item.h/100*o.height)
                x = item.x/100*o.width
                y = item.y/100*o.height
                w = item.w/100*o.width
                #
                if item.type is 'qr'
                  #
                  ctx.drawImage item.qr_img, item.x/100*o.width,item.y/100*o.height, item.w/100*o.width, item.h/100*o.height
          #
          line_i = 0
          #
          for item, i in theme.items
            do (item) ->
              if item.side*1 is o.side*1
                h = Math.round(item.h/100*o.height)
                x = item.x/100*o.width
                y = item.y/100*o.height
                w = item.w/100*o.width
                #
                if item.type is 'line'
                  #
                  ctx.fillStyle = hex_to_rgba item.color
                  ctx.font = h + 'px "' + item.font_family + '"'
                  #
                  this_line_copy =  o.values[line_i] or ''
                  this_line_copy = this_line_copy.replace(/&nbsp;/g, ' ').replace(/\n/g, '')
                  #
                  if item.text_align is 'left'
                    ctx.fillText this_line_copy, x, y+h
                  else
                    measure = ctx.measureText this_line_copy, x, y+h
                    if item.text_align is 'right'
                      ctx.fillText this_line_copy, x+w-measure.width, y+h
                    if item.text_align is 'center'
                      ctx.fillText this_line_copy, x+(w-measure.width)/2, y+h
                  #
                  #
                #
              #
              #
              if item.type is 'line'
                line_i++
          #
          #
          #
          canvas.toBuffer (err, buff) ->
            o.res.send buff,
              'Content-Type': 'image/png'
            , 200
            #
            #
            #
            if o.thumb_cache
              # Send that new file to Amazon to be saved!
              knoxReq = knoxClient.put '/thumb_cache/'+o.side+'/'+theme._id,
                'Content-Length': buff.length
                'Content-Type' : 'image/png'
              knoxReq.on 'response', (awsRes) ->
                if awsRes.statusCode != 200
                  console.log 'ERR', awsRes
                else
                  theme.cache = [false,false] unless theme.cache
                  theme.cache[o.side] = true
                  theme.save maybe_log_err
              knoxReq.end buff
      #
      #
      for item, i in theme.items
        #
        do (item) ->
          #
          if item.side*1 is o.side*1
            #
            if item.type is 'qr'
              #
              #
              alpha = Math.round(item.color_2_opacity * 255).toString 16
              #
              qr_canvas = qr_code.draw_qr
                node_canvas: node_canvas
                style: item.qr_style
                url: o.url
                hex: item.color
                hex_2: item.color_2+alpha
              #
              need_to_wait_on++
              #
              qr_canvas.toBuffer (err, qr_buff) ->
                qr_img = new node_canvas.Image
                qr_img.src = qr_buff
                #
                item.qr_img = qr_img
                #
                need_to_wait_on--
                #
                check_if_done()
            #
            #
            if item.type is 'image'
              #
              #
              if item.s3_id
                #
                need_to_wait_on++
                #
                request = http.get
                  host: 'd3eo3eito2cquu.cloudfront.net'
                  port: 80
                  path: '/'+o.widthheight+'/'+item.s3_id
                , (response) ->
                    #
                    response.setEncoding 'binary'
                    #
                    response.on 'data', (chunk) ->
                      imagedata += chunk
                    response.on 'end', ->
                      if response.statusCode is 200
                        buff = new Buffer imagedata, 'binary'
                        img = new node_canvas.Image
                        img.src = buff
                        #
                        item.img = img
                        #
                        need_to_wait_on--
                        #
                        check_if_done()
#
#
#
#
#
#
#
# Success Page
#
# Where they land after authenticating
# This should close automatically or redirect to the home page if no caller
app.get '/success', (req, res) ->
  res.cookie 'success_login', true
  res.send '<script>window.onload = function(){window.close();}',
    'Content-Type': 'text/html'
  , 200
#
# Get the order information
get_order_info = (req, res, next) ->
  mongo_order.find
    user_id: req.user._id
    'charge.paid': true
  , (err, orders) ->
    if check_no_err err, res
      req.orders = orders
      next()
#
#
#
get_url_groups = (req, res, next) ->
  if req.user
    mongo_url_group.find
      user_id: req.user._id
    , (err, url_groups) ->
      if check_no_err err
        #
        #
        for url_group in url_groups
          #
          #
          #
          #
          #
          url_group.range = url_group.urls[0].card_number+'-'+url_group.urls[url_group.urls.length-1].card_number
          #
          #
          # Sort by last updated within the url groups
          url_group.urls = _(url_group.urls).sortBy (url) ->
            url.last_updated
          url_group.urls.reverse()
          #
          #
          #
          #
          # -
          # ------
          # ---------------
          # --------------------------------------------------
          # Try to group the ranges of numbers, BLEGH! :O
          #
          #
          url_group.ranged_urls = []
          #
          # Get the groups
          # Filter out the visited
          not_visited = _(url_group.urls).filter (url) ->
            url.visits*1 is 0 and url.redirect_to isnt url_group.redirect_to
          #
          #

          at_defaults = _(url_group.urls).filter (url) ->
            url.visits*1 is 0 and url.redirect_to is url_group.redirect_to
          #
          url_group.at_defaults = at_defaults.length
          #
          #
          grouped = _(not_visited).groupBy (url) ->
            url.redirect_to
          for redirect_to,group of grouped
            #
            #
            group = _(group).sortBy (url) ->
              url.card_number
            #
            #
            final = group[0]
            #
            prev_card_number = final.card_number-1
            length = 0
            for url in group
              if url.card_number*1 isnt prev_card_number*1+1
                if length > 1
                  final.card_number = final.card_number + '-' + prev_card_number
                final.card_number = final.card_number + ', ' + url.card_number
                length = 0
              length++
              prev_card_number = url.card_number
              #
            #
            if length > 1
              final.card_number = final.card_number + '-' + prev_card_number
            #
            #
            url_group.ranged_urls.push final
          #
          #
          #
          # --------------------------------------------------
          # ---------------
          # ------
          # -
          #
          #
        #
        #
        #
        req.url_groups = url_groups
        #
        next()
  else
    next()
#
#
#
#
# Make me an admin
app.get '/make-me-admin', secured_page, (req, res) ->
  req.user.role = 'admin'
  req.user.save (err) ->
    log_err err if err
    res.send '',
      Location: '/admin'
    , 302
#
#
#
# About Page
app.get '/about', (req, res) ->
  res.render 'about'
    req: req

# Cards Page
app.get '/cards/:page_type?', secured_page, (req, res) ->
  #
  res.render 'cards'
    req: req



# Learn More Page
app.get '/learn-more', (req, res) ->
  res.render 'learn_more'
    req: req
#
#
#

# Redirect for Kickstarter campagin
app.get '/fundourprinter', (req, res, next) ->
  console.log req.url
  res.send '',
    Location:'http://www.kickstarter.com/projects/cardsly/cardsly-qr-code-business-cards'
  , 301
  
# Splash Page
app.get '/old-browser', (req, res) -> 
  res.render 'old_browser'
    req: req
    layout: 'layout_min'
#
# Error Page
app.get '/error', (req, res) -> 
  res.render 'error'
    req: req
    layout: 'layout_min'

# Cute Animal PAges
app.get '/cute-animal', (req, res) -> 
  res.render 'cute_animal'
    req: req
    layout: 'layout_min'
#
#
OAuth = require('oauth').OAuth
#
#
app.get '/thumb/:theme_id/:side?', (req, res, next) ->
  #
  #
  url = '1'
  parts = req.url.split '?'
  if parts.length > 1
    url = unescape req.url.replace /^[^\?]*\?/i, ''
  #
  render_image
    res: res
    widthheight: '158x90'
    thumb_cache: true
    width: 158
    height: 90
    values: default_line_copy
    active_view: 0
    theme_id: req.params.theme_id
    side: req.params.side
    url: url
#
#
#
app.get '/test/:theme_id', (req, res, next) ->
  #
  #
  url = '1'
  parts = req.url.split '?'
  if parts.length > 1
    url = unescape req.url.replace /^[^\?]*\?/i, ''
  #
  render_image
    res: res
    widthheight: 'raw'
    width: 1050
    height: 600
    values: default_line_copy
    theme_id: req.params.theme_id
    side: 0
    url: url
#
#
#
app.get '/render/:w/:h/:order_id', (req, res, next) ->
  #
  height = req.params.h*1
  width = req.params.w*1
  widthheight = 'raw' if settings.width > 525
  widthheight = '158x90' if settings.width < 158
  widthheight = '525x300' if settings.width > 158 and settings.width < 525
  #
  #
  url = 'cards.ly'
  parts = req.url.split '?'
  if parts.length > 1
    url = unescape req.url.replace /^[^\?]*\?/i, ''
  #
  #
  mongo_order.findById req.params.order_id, (err, order) ->
    #
    #
    #
    render_image
      res: res
      widthheight: widthheight
      width: width
      height: height
      theme_id: order.theme_id
      values: order.values
      active_view: order.active_view
      url: url
#
#
#
#
#
# Make me an admin
app.get '/make-me-admin', secured_page, (req, res) ->
  req.user.role = 'admin'
  req.user.save (err) ->
    log_err err if err
    res.send '',
      Location: '/admin'
    , 302
#
#
#
#
#
app.get '/gangplank', (req, res) ->
  res.render 'gangplank'
    req: req
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Hello Gangplank!'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    #
    # (Uncomment means remove the single # character at the start of it :)\
#
# AB Test Pages

# Page 1 Purchase
app.get '/home1', get_url_groups, (req, res) ->
  res.render 'home'
    req: req
    abtest: 1
    url_groups: req.url_groups
    scripts:[
      'home'
    ]


# Page 2 Checkout
app.get '/home2', get_url_groups, (req, res) ->
  res.render 'home'
    req: req
    abtest: 2
    url_groups: req.url_groups
    scripts:[
      'home'
    ]

# Page 3 Buy
app.get '/home3', get_url_groups, (req, res) ->
  res.render 'home'
    req: req
    abtest: 3
    url_groups: req.url_groups
    scripts:[
      'home'
    ]

#
#
# Real Index Page
app.get '/talking', get_url_groups, (req, res) -> 
  #
  #
  #
  res.render 'home'
    req: req
    abtest: 4
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own QR code business cards. See analytics and update links anytime in the Cardsly dashboard.'
    #
    # Uncomment the following line to add a custom h1 tag!
    h1: 'Talking business cards send you Email Alerts'
    #
    # (Uncomment means remove the single # character at the start of it :)
    #
    url_groups: req.url_groups
    #
#
#
#
#
#
#
#
#
# Real Index Page
app.get '/', (req, res) -> 
  #
  #
  res.render 'home'
    req: req
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own QR code business cards. See analytics and update links anytime in the Cardsly dashboard.'
    #
    #
    # (Uncomment means remove the single # character at the start of it :)
    #
#
#
#
#

# About Page
app.get '/about', (req, res) ->
  res.render 'about'
    req: req
#

# About Page
app.get '/alerts', (req, res) ->
  res.render 'alerts'
    req: req
#

# Redirect for Kickstarter campagin
app.get '/fundourprinter', (req, res, next) ->
  console.log req.url
  res.send '',
    Location:'http://www.kickstarter.com/projects/cardsly/cardsly-qr-code-business-cards'
  , 301
#
#
app.get '/qr/:color?/:color_2?/:style?', (req, res, next) ->

  params =
    url: 'http://cards.ly'
    hex: '000000'
    round: 5
    style: 'round'
    hex_2: 'transparent'

  
  
  parts = req.url.split '?'
  if parts.length > 1
    params.url = unescape req.url.replace /^[^\?]*\?/i, ''
  

  if req.params.color
    if req.params.color.match /[a-f0-9]{6,8}/i
      params.hex = req.params.color
    else
      params.style = req.params.color

  if req.params.color_2
    if req.params.color_2.match /[a-f0-9]{6,8}/i
      params.hex_2 = req.params.color_2
    else
      params.style = req.params.color_2
  #
  #
  if req.params.style
    params.style = req.params.style
  #
  #
  #
  canvas = qr_code.draw_qr
    node_canvas: node_canvas
    style: params.style
    url: params.url
    hex: params.hex
    hex_2: params.hex_2


  canvas.toBuffer (err, buff) ->
    res.send buff,
      'Content-Type': 'image/png'
    , 200

  
  ###


#
#
#
#
#
#
#
#
#
#
#
#
#
#
# END GET ROUTES
#
#
#
#
###########################################################

























###########################################################
#
#
#
#
###

Generic Routes

- error handlers
- redirects
- robots.txt
- etc

###
#
#
#
#
# Generic Error handler page itself
app.get '/error', (req, res) ->
  res.render 'error'
#
# Robots.txt to tell google it's cool to crawl
app.get '/robots.txt', (req, res, next) ->
  res.send 'user-agent: *\nDisallow: ',
    'Content-Type': 'text/plain'
# Robots.txt to tell google it's cool to crawl
app.get '/js/libs/PIE', (req, res, next) ->
  res.sendfile __dirname + '/assets/js/libs/PIE.htc',
    'Content-Type': 'text/x-component'
#
#
# Default Route
#
# Redirect everything to the home page automagically
app.get '*', (req, res, next) ->
  console.log req.url
  res.send '',
    Location:'/'
  , 301
#
#
#
# ### Start server
app.listen process.env.PORT or 4000
#
###
server.listen
  server: app
  io:
    transports: ['xhr-polling']
###
#
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
#
#
#
#
# END Generic Routes
#
#
#
#
###########################################################