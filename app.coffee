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
# Image Magick for graphic editing
im = require 'imagemagick'
#
#
xml2json = require 'xml2json'
#
samurai = require 'samurai'
samurai.setup
  merchant_key: '89b14db44561382d457b5160'
  merchant_password: '6a5a0bf8906a6b8b1e577d72'
  processor_token: '5c44e876a2d1125015a872c3'  
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
require './assets/js/date'
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
#
#
#
# MOO API Key
# 4739b76c5a56a3c0f03bfcefd3248ed804ed95ae2
# 
# MOO Secret
# bec6f97d58f1121cd90e16502e6c8e4e
#
#
# END LIBRARY LOADING
#
#
###########################################################


ua_match =  (ua) ->
  ua = ua.toLowerCase()

  rwebkit = /(webkit)[ \/]([\w.]+)/
  ropera = /(opera)(?:.*version)?[ \/]([\w.]+)/
  rmsie = /(msie) ([\w.]+)/
  rmozilla = /(mozilla)(?:.*? rv:([\w.]+))?/

  match = rwebkit.exec( ua ) or ropera.exec( ua ) or rmsie.exec( ua ) or ua.indexOf('compatible') < 0 and rmozilla.exec( ua ) or []

  result =
    browser: match[1] or ''
    version: match[2] or '0'














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
  password_encrypted: String
  role: String
  name: String
  title: String
  phone: String
  company: String
  fax: String
  address: String
  address_2: String
  twitter_url: String
  facebook_url: String
  linkedin_url: String
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
    , (err,founduser) ->
      if err
        next 'Database Error'
      else
        if founduser
          if !founduser.password_encrypted
            next 'That email address is currently registered with a social account.<p>Please try logging in with a social network such as facebook or twitter.'
          else if compareEncrypted password, founduser.password_encrypted
            next null, founduser
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
# cards
card_schema = new schema
  user_id: String
  print_id: Number
  path: String
  theme_id: String
  active_view: Number
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
mongo_card = mongoose.model 'cards', card_schema
#
#
#
#
# Messages
message_schema = new schema
  include_contact: Boolean
  content: String
  s3_id: String
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
mongo_message = mongoose.model 'messages', message_schema
#
#
#
#
# Style Field Positions
line_schema = new schema
  order_id: Number
  color: String
  font_family: String
  text_align: String
  h: Number
  w: Number
  x: Number
  y: Number
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
# Themes
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
#
#
#
# Groups of Themes
theme_schema = new schema
  user_id: String
  category: String
  theme_templates: [theme_template_schema]
  color1: String
  color2: String
  s3_id: String
  date_updated:
    type: Date
    default: Date.now
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true

mongo_theme = mongoose.model 'themes', theme_schema
#
#
#

mongo_theme.find
  s3_id: null
  theme_templates:
    '$elemMatch':
      s3_id:
        '$exists': true
, (err, themes) ->
  for theme in themes
    if theme.theme_templates[0].s3_id
      theme.s3_id = theme.theme_templates[0].s3_id
      theme.save()



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
  active_view: Number
  status: String
  status_history: [status_schema]
  quantity: Number
  shipping_method: Number
  tracking_number: String
  values: [String]
  address: String
  city: String
  full_address: String
  amount: Number
  email: String
  shipping_email: String
  confirm_email: String
  s3_id: String
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
# Password Reset
password_reset = new schema
  password_reset: Date
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
handleGoodResponse = (session, accessToken, accessTokenSecret, userMeta) ->
  #
  #console.log 'userMeta', userMeta
  #
  promise = new Promise()
  #
  #console.log userMeta
  #
  userSearch = {}
  if userMeta.publicProfileUrl
    userSearch.name = userMeta.firstName+' '+userMeta.lastName
    userSearch.linkedin_url = userMeta.publicProfileUrl
  if userMeta.link
    userSearch.name = userMeta.name
    userSearch.facebook_url = userMeta.link
  if userMeta.screen_name
    userSearch.name = userMeta.name
    userSearch.twitter_url = 'http://twitter.com/#!'+userMeta.screen_name
  if userMeta.email
    userSearch.email = userMeta.email
  #
  mongo_user.findOne userSearch, (err,existinguser) ->
    if err
      log_err err
      promise.fail err
    else if existinguser
      #console.log 'user exists: ', existinguser
      promise.fulfill existinguser
    else
      user = new mongo_user
      user.name = userSearch.name
      user.linkedin_url = userSearch.linkedin_url
      user.facebook_url = userSearch.facebook_url
      user.twitter_url = userSearch.twitter_url
      user.email = userSearch.email
      user.save (err, createduser) -> 
        if err
          log_err err
          promise.fail err
        else
          #console.log 'user created: ', createduser
          promise.fulfill createduser
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










###
TODO

- Pass the entire "req" object to jade files -- automatigically??

###








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
connect = require 'connect'
redis_store = require('connect-redis') connect

options = {}
if process.env.REDISTOGO_URL
  options = 
    host: process.env.REDISTOGO_URL.replace /.*@([^:]*).*/ig, '$1'
    port: process.env.REDISTOGO_URL.replace /.*@.*:([^\/]*).*/ig, '$1'
    pass: process.env.REDISTOGO_URL.replace /.*:.*:(.*)@.*/ig, '$1'
session_store = new redis_store options
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
    h1: '<span>QR code business cards done easi<span class="alt">ly</span></span>'
    #
    #
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

create_new_url 'http://url-I-want-to-redirect-to.com', (err, new_url) ->
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
app.post '/save-main-redirect', (req, res) ->
  #
  # Set up the redirect
  if not req.body.redirect_to.match /http:\/\//i
    req.body.redirect_to = 'http://'+req.body.redirect_to
  #
  mongo_url_group.findById req.body.url_group_id, (err, url_group) ->
    if check_no_err_ajax err, res
      if url_group.user_id+'' isnt req.user._id+''
        res.send
          err: 'No Permission'
      else
        for url in url_group.urls
          if url.redirect_to is url_group.redirect_to and url.visits*1 is 0
            url.redirect_to = req.body.redirect_to
            url.last_updated = new Date()

            mongo_url_redirect.findOne
              url_string: url.url_string
            , (err, url_redirect) ->
              if not err
                url_redirect.redirect_to = req.body.redirect_to
                url_redirect.save()
        url_group.redirect_to = req.body.redirect_to
        url_group.save (err, saved_url_group) ->
          if check_no_err_ajax err, res
            res.send
              success: true
#
#
app.post '/save-redirect', (req, res) ->
  #
  # Set up the redirect
  if not req.body.redirect_to.match /http:\/\//i
    req.body.redirect_to = 'http://'+req.body.redirect_to
  #
  # Set up the Card Numbers from the range given
  card_numbers = []
  parts = req.body.range.split ','
  for part in parts
    range = part.split '-'
    spaced = part.split ' '
    if range.length > 1
      card_numbers.push(i) for i in [range[0]..range[1]]
    else if spaced.length > 1
      card_numbers.push(i) for i in spaced
    else
      card_numbers.push part
  for card_number,i in card_numbers
    card_numbers[i] = card_number*1
  #
  #
  mongo_url_group.findById req.body.url_group_id, (err, url_group) ->
    if check_no_err_ajax err, res
      if url_group.user_id+'' isnt req.user._id+''
        res.send
          err: 'No Permission'
      else
        for url in url_group.urls
          if _(card_numbers).contains url.card_number*1
            url.redirect_to = req.body.redirect_to
            url.last_updated = new Date()
            mongo_url_redirect.findOne
              url_string: url.url_string
            , (err, url_redirect) ->
              if not err
                url_redirect.redirect_to = req.body.redirect_to
                url_redirect.save()
        url_group.save (err, saved_url_group) ->
          if check_no_err_ajax err, res
            res.send
              success: true
#
#
#
app.post  '/get-visits', (req, res) ->
  mongo_visit.find
    url_string: req.body.url_string
    , (err, visits) ->
      if check_no_err_ajax err, res
        sorted_visits = _(visits).sortBy (visit) -> visit.date_added
        sorted_visits.reverse()
        sent_visits = []
        for visit in sorted_visits
          ua =  ua_match visit.user_agent
          has_word = (word) -> Boolean visit.user_agent.match new RegExp(word,'i')
          sent_visits.push
            browser: (if has_word('chrome') then 'Chrome' else if has_word('msie') then 'IE' else if has_word('firefox') then 'Firefox' else if has_word('iphone') then 'iPhone' else if has_word('ipad') then 'iPad' else if has_word('android') then 'Android' else if has_word('safari') then 'Safari' else 'Other')+(if has_word('mobile') then ' Mobile' else '')
            location: visit.details.city+', '+visit.details.state+' '+visit.details.iso
            date_added: visit.date_added
        res.send
          visits: sent_visits  
#
#
app.post '/update-order-status', (req, res) ->
  mongo_order.findById req.body.order_id, (err, order) ->
    if check_no_err_ajax err, res
      order.status = req.body.status
      order.save (err, saved_order) ->
        if check_no_err_ajax err, res
          res.send
            success: true
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
  console.log req.form
  console.log 2
  #
  # Find the file we just created
  path = req.body.image.path
  #
  #
  # Identify it's filname
  #
  #
  s3_id = random_url()+random_url()+random_url()+'.png'
  #
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
      console.log 3
      #
      buff = new Buffer rawImg, 'binary'
      img = new node_canvas.Image
      img.src = buff
      #
      #
      console.log img.width, img.height
      #
      #
      #
      save_image_to = (width, height, dir) ->
          #
          #
          #
          canvas = new node_canvas(width,height)
          ctx = canvas.getContext '2d'
          #
          ctx.drawImage img, 0, 0, width, height
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
                console.log 'ERR', awsRes
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
# AJAX request for saving theme
app.post '/save-theme', (req, res) ->
  #
  # Put it into a nice pretty JSON object 
  params = req.body
  #
  #
  #
  # If we hit the save button
  if params.do_save
    #
    # If we're updating do this
    if params.theme._id
      mongo_theme.findById params.theme._id, (err, found_theme) ->
        if check_no_err_ajax err, res
          found_theme.date_updated = new Date()
          if typeof(params.theme.active) is 'boolean'
            found_theme.active = params.theme.active
          found_theme.category = params.theme.category
          found_theme.s3_id = params.theme.s3_id
          if params.theme.category is 'My Own'
            if req.user and req.user._id
              found_theme.user_id = req.user._id
            else
              found_theme.user_id = req.sessionID
          #
          # Push the new template in
          found_theme.theme_templates = params.theme.theme_templates
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
      new_theme = new mongo_theme
      if typeof(params.theme.active) is 'boolean'
        new_theme.active = params.theme.active
      new_theme.category = params.theme.category
      new_theme.s3_id = params.theme.s3_id
      if params.theme.category is 'My Own'
        if req.user and req.user._id
          new_theme.user_id = req.user._id
        else
          new_theme.user_id = req.sessionID
      #
      # Push the new template in
      new_theme.theme_templates = params.theme.theme_templates
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
app.post '/save-form', (req, res) ->
  ###
  TODO
  
  We're going to have to save these form inputs in a cookie that expires faster.
  Like on browser close.
  It will be bad if someone else on the same computer comes to the page 2 weeks later and the first persons data is still showing there.
  Someone might be bothered by the privacy implications, even though it's data they put on their business cards which is fairly public.

  ###
  # Put it into a nice pretty JSON object 
  req.session.saved_form = req.body
  res.send
    success: true
#
#
#
app.post '/find-address', (req, res, next) ->
  geo.geocoder geo.google, req.body.address+' '+req.body.city, false, (full_address, latitude, longitude, details) ->
    #console.log full_address, latitude, longitude, details
    full_address = full_address.replace /,/, '<br>'
    req.session.saved_address =
      address: req.body.address
      city: req.body.city
      full_address: full_address
      latitude: latitude
      longitude: longitude
      details: details
    res.send
      full_address: full_address
      latitude: latitude
      longitude: longitude
#
#
#
#
#
# Make Sure an email isn't taken
app.post '/check-email', (req, res, next) ->
  params = req.body || {}
  req.email = params.email || ''
  req.email = req.email.toLowerCase()
  handleReturn = (err, count) ->
    req.err = err
    req.count = count
    next()
  if params.id
    mongo_user.count
      email:req.email
      active:true
    , handleReturn
  else
    mongo_user.count
      email: req.email
      active:true
    , handleReturn
,(req, res, next) ->
  res.send
    err: req.err
    count: req.count
    email: req.email
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
# Sends feedback to us
app.post '/send-feedback', (req,res,next) ->
  res.send
      succesfulFeedback:'This worked!'
  nodemailer.send_mail
    sender: req.body.email or 'help@cards.ly'
    to: 'support@cards.ly'
    cc: 'help@cards.ly'
    subject:'Feedback email from:' + req.body.email
    html: '<p>This is some feedback</p><p>' + req.body.content + '</p>'
  , (err, data) ->
    if err
      log_err err
#
#
#
#
# Create the new sign up
app.post '/create-user', (req,res,next) ->
  mongo_user.count
    email:req.body.email
    active:true
  ,(err,already) ->
    if already>0
      res.send
        err: 'It looks like that email address is already registered with an account. It might be a social network account.<p>Try signing with a social network, such as facebook, linkedin, google+ or twitter.'
    else
      next()
,(req,res,next) ->
  user = new mongo_user()
  user.email = req.body.email;
  user.password_encrypted = encrypted(req.body.password);
  user.save (err,data) ->
    req.session.auth = 
      userId: user._id
    res.send
      success: 'True'
#
#
#
#
# Change Password
app.post '/change-password', (req,res,next) ->
  #
  #
  if !req.user.email or !req.body.current_password
    res.send
      err: 'Invalid Parameters'
  else
    mongo_user.authenticate req.user.email, req.body.current_password, (err, user) ->
      if err or !user
        res.send
          err: err or 'User not found'
      else
        req.user.password_encrypted = encrypted req.body.new_password
        req.user.save (err, user_saved) ->
          if check_no_err_ajax err, res
            res.send
              success: true
#
#
#

#Password Reset and Sending Email
app.post '/send-password-reset', (req,res,next) ->
  res.send
    succesfulFeedback:'This worked!'
  nodemailer.send_mail
    sender: 'supportcards.ly'
    to: req.body.email_password
    subject:'Password Reset from Cardsly'
    html: '<p>Please click the following link to change the password of your Cardsly account</p>'
  , (err, data) ->
    if err
      log_err err



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
get_patterns = (req, res, next) ->
  mongo_pattern.find
    active: true
  , (err, patterns) ->
    if check_no_err_ajax err, res
      req.patterns = patterns
      next()
#
#
#
app.post '/get-patterns', get_patterns, (req, res, next) ->
  res.send
    patterns: req.patterns
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
  if req.user.stripe
    req.user.stripe.id = null
  res.send
    name: req.user.name
    email: req.user.email
    stripe: req.user.stripe
    session: req.session

#
#
#
#
#
#
#
#
# Get Themes (post route for get themes :)
app.post '/get-themes', (req,res,next) ->
  #
  #
  #
  user_to_find = null
  #
  #
  #
  if req.user and req.user._id
    user_to_find = 
      $in: [null,req.user._id]
  #
  else if req.sessionID
    user_to_find = 
      $in: [null,req.sessionID]
  #
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
add_urls_to_order = (order, user, res) ->
  #
  #
  #
  redirect_to = 'http://cards.ly/'+order.order_number
  for value in order.values
    parsed = value.replace /(&nbsp;|\n)/ig, ''
    if parsed.match(/[a-z0-9]{2,}\.[a-z0-9]{2,}/i) and not parsed.match(/@/)
      redirect_to = parsed
  if not redirect_to.match /http:\/\//
    redirect_to = 'http://'+redirect_to
  #
  # Generate order urls, based on "quantity" (which isnt really quantity)
  #
  volume = 100
  volume = 250 if order.quantity*1 is 25
  volume = 500 if order.quantity*1 is 35
  volume = 1500 if order.quantity*1 is 70

  #
  #
  create_urls
    redirect_to: redirect_to
    volume: volume
  , (err, new_urls) ->

    url_group = new mongo_url_group
    url_group.order_id = order._id
    url_group.user_id = user._id
    url_group.redirect_to = redirect_to
    url_group.urls = []
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
image_err = (res) ->
  height = 100
  width = 300
  canvas = new node_canvas(width,height)
  ctx = canvas.getContext '2d'
  ctx.font = Math.round(40/100*height) + 'px Arial'
  ctx.fillText 'whoops', width/2-40/100*width, height/2
  #
  canvas.toBuffer (err, buff) ->
    res.send buff,
      'Content-Type': 'image/png'
    , 200
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
            short_domain = 'http://cards.ly/'
            if process.env and process.env.SHORT_URL
              short_domain = 'http://'+process.env.SHORT_URL+'/'
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
  #
  # Find the Order that's passed in
  mongo_order.findById order_id, (err, order) ->
    #
    #
    # Find the theme for that order
    mongo_theme.findById order.theme_id, (err, theme) ->
      #
      #
      # Find the urls we're going to use
      mongo_url_group.findOne
        order_id: order._id
      , (err, url_group) ->
        #
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
          #
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
app.post '/confirm-purchase', (req, res, next) ->
  order = new mongo_order
  order.user_id = req.user._id
  order.theme_id = req.session.saved_form.active_theme_id
  order.active_view = req.session.saved_form.active_view
  order.status = 'Pending'
  order.quantity = req.session.saved_form.quantity
  order.shipping_method = req.session.saved_form.shipping_method
  order.values = req.session.saved_form.values
  order.address = req.session.saved_address.address
  order.city = req.session.saved_address.city
  order.full_address = req.session.saved_address.full_address
  order.amount = (req.session.saved_form.quantity*1 + req.session.saved_form.shipping_method*1) * 100
  order.email = req.body.email
  #
  #
  #
  # Save email if passed in.
  if req.body.email
    req.user.email = req.body.email
    req.user.save (err, user_saved) ->
      if err
        log_err err
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
          email: req.user.email or null
          description: req.user.name or req.user.email or req.user.id
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
  #
  # Attempt a charge
  stripe.charges.create
    currency: 'usd'
    amount: new_order.amount*1
    customer: req.user.stripe.id
    description: req.user.name + ', ' + req.user.email + ', ' + new_order._id
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
        else if not charge.paid
          console.log 'ERR: stripe charge resulted in not paid for some reason.'
          res.send
            err: 'Charge resulted in not paid for some reason.'
        else
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
          # Prep the Email Message
          total_paid = new_order.amount/100
          message = '<p>' + (req.user.name or req.user.email) + ',</p><p>We\'ve received your order and are processing it now.</p><p>Here are the details of your order: </p> <p><b>Order ID: </b>'+new_order.order_number+'</p></p> <p><b>Amount of Cards: </b>'+volume+'</p></p> <p><b>Total Paid: </b>$'+total_paid+'</p><p> Please don\'t hesitate to let us know if you have any questions at any time. <p>Reply to this email, call us at 480.428.8000, or reach <a href="http://twitter.com/cardsly">us</a> on <a href="http://facebook.com/cardsly">any</a> <a href="https://plus.google.com/101327189030192478503/posts">social network</a>. </p>'
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
app.post '/validate-purchase', (req, res, next) ->
  #
  #
  #
  if not req.user
    res.send
      error: 'Please sign in'
  else if not req.session.saved_address
    res.send
      error: 'Please enter shipping info'
  else if not req.session.saved_address.full_address
    res.send
      error: 'Please check the address'
  else if req.session.saved_form.values[0] is "1) John Stamos"
    res.send
      error: 'Hey Uncle Jesse, is that you?'
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
      success: true
    ###
    res.send
      error: 'Im sorry this page isnt active yet'
    ###
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
securedAdminPage = (req, res, next) ->
  if req.user && req.user.role == 'admin'
    next()
  else
    res.send '',
      Location: '/cards'
    ,302
securedPage = (req, res, next) ->
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
#
#
#
app.get '/[A-Za-z0-9]{5,}/?$', (req, res, next) ->
  #
  # Prep the string to search for
  search_string = req.url.replace /[^a-z0-9]/ig, ''
  #
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
              card_number = 0
              for url in url_group.urls
                if url.url_string is search_string
                  if not url.visits
                    url.visits = 0
                  url.visits++
                  url.last_updated = new Date()
                  card_number = url.card_number
              url_group.save (err, saved_url_group) ->
                log_err err if err
              #
              #
              #
              console.log card_number
              #
              if card_number
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

                    ua =  ua_match visit.user_agent
                    has_word = (word) -> Boolean visit.user_agent.match new RegExp(word,'i')
                    visit_details =
                      browser: (if has_word('chrome') then 'Chrome' else if has_word('msie') then 'IE' else if has_word('firefox') then 'Firefox' else if has_word('iphone') then 'iPhone' else if has_word('ipad') then 'iPad' else if has_word('android') then 'Android' else if has_word('safari') then 'Safari' else 'Other')+(if has_word('mobile') then ' Mobile' else '')
                      location: visit.details.city+', '+visit.details.state+' '+visit.details.iso
                      date_added: visit.date_added
                    #
                    console.log '<p>Someone just scanned card #'+card_number+' from their '+visit_details.browser+' in '+visit_details.location+'.</p><p>Check out your full dashboard at <a href="http://cards.ly">cards.ly</a></p>'
                    #
                    # Send it!
                    nodemailer.send_mail
                      sender: 'help@cards.ly'
                      to: found_user.email
                      subject: 'Card #'+card_number+' was just scanned!'
                      html: '<p>Someone just scanned card #'+card_number+' from their '+visit_details.browser+' in '+visit_details.location+'.</p><p>Check out your full dashboard at <a href="http://cards.ly">cards.ly</a></p>'
                    , (err, data) ->
                      if err
                        log_err err
    #

                
#
#
#
#
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
app.get '/update-patterns', (req, res, next) ->
  mongo_pattern.find
    active: true
  , (err, patterns) ->
    for pattern in patterns
      pattern.active = false
      pattern.save()
  http_request 'http://feeds.feedburner.com/SubtlePatterns', (err, response, body) ->
    parsed = xml2json.toJson body,
      object: true
    for pattern,i in parsed.rss.channel.item
      png_links = pattern['content:encoded'].match /[^"^\(]*\.png/ig
      do (png_links) ->
        if png_links and png_links.length
          #
          #
          #
          imagedata = ''
          #
          #
          #
          request = http.get
            host: 'subtlepatterns.com'
            port: 80
            path: '/'+png_links[0]
          , (response) ->
              #
              #
              #
              response.setEncoding 'binary'
              #
              #
              #
              response.on 'data', (chunk) ->
                imagedata += chunk
              response.on 'end', ->
                if response.statusCode is 200
                  #
                  #
                  buff = new Buffer imagedata, 'binary'
                  #
                  img = new node_canvas.Image
                  img.src = buff
                  #
                  #
                  my_new_id = random_url()+random_url()+random_url()+'.png'
                  #
                  save_pattern_to = (width, height, dir) ->
                      #
                      #
                      if width is 50
                        new_w = Math.round img.width/4
                        new_h = Math.round img.height/4
                      else
                        new_w = img.width
                        new_h = img.height
                      #
                      #
                      canvas = new node_canvas(width,height)
                      ctx = canvas.getContext '2d'
                      #
                      #
                      t = 0
                      l = 0
                      add_row = ->
                        l = 0
                        ctx.drawImage img, l, t, new_w, new_h
                        l += new_w
                        add_col = ->
                          ctx.drawImage img, l, t, new_w, new_h
                          l += new_w
                        add_col() while l < width
                        t += new_h
                      add_row() while t < height
                      #
                      canvas.toBuffer (err, canvas_buff) ->
                        log_err err if err
                        #
                        # Send that new file to Amazon to be saved!
                        knoxReq = knoxClient.put '/'+dir+'/'+my_new_id,
                          'Content-Length': canvas_buff.length
                          'Content-Type' : 'image/png'
                        knoxReq.on 'response', (awsRes) ->
                          if awsRes.statusCode != 200
                            console.log 'ERR', awsRes
                        knoxReq.end canvas_buff
                  #
                  #
                  save_pattern_to 50, 50, 'pattern-thumbs'
                  save_pattern_to 1050, 600, 'raw'
                  save_pattern_to 158, 90, '158x90'
                  save_pattern_to 525, 300, '525x300'
                  #
                  pattern = new mongo_pattern
                  pattern.s3_id = my_new_id
                  pattern.title = png_links[1]
                  pattern.save()
                  #
    #
    #
    #
    res.send
      blegh: true
#
#
#
#
#
#
#
app.get '/re-process-pdf/:order_id', (req, res, next) ->
  #
  #
  # This is where we kick off the processing of the pdf
  process_pdf req.params.order_id
  #
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
app.get '/test/:theme_id', (req, res, next) ->
  #
  #
  # Find the theme for that order
  mongo_theme.findById req.params.theme_id, (err, theme) ->
    #
    # The theme_template used based on the view from the order
    theme_template = theme.theme_templates[0]
    #
    urls =
      (
        url_string: 'test'
        card_number: i
      ) for i in [1..10]
    #
    render_urls_to_doc urls, theme_template, [
      'Jimbo jo Jiming'
      'Banker Extraordinaire'
      'Cool Cats Cucumbers'
      '57 Bakers, Edwarstonville'
      '555.555.5555'
      'New York'
      'Apt. #666'
      'M thru F - 10 to 7'
      'fb.com/my_facebook'
      '@my_twitter'
    ], theme.s3_id, (doc) ->
      #
      # FINALLY - Send it to the browser
      #
      res.send new Buffer(doc.output(), 'binary'),
        'Content-Type' : 'application/pdf'
      , 200
    #
    #
#
#
app.get '/render/:w/:h/:order_id', (req, res, next) ->
  #
  height = req.params.h*1
  width = req.params.w*1
  widthheight = width+'x'+height
  widthheight = 'raw' if width is 1680
  widthheight = 'raw' if width is 1050
  widthheight = '158x90' if width is 79
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
    #
    mongo_theme.findById order.theme_id, (err, theme) ->
      theme_template = theme.theme_templates[order.active_view]
      if not order.active_view
        image_err res
      else
        #
        imagedata = ''
        #
        request = http.get
          host: 'd3eo3eito2cquu.cloudfront.net'
          port: 80
          path: '/'+widthheight+'/'+theme.s3_id
        , (response) ->
            #
            response.setEncoding 'binary'
            #
            response.on 'data', (chunk) ->
              imagedata += chunk
            response.on 'end', ->

              if response.statusCode is 200
                buff = new Buffer imagedata, 'binary'


                canvas = new node_canvas(width,height)
                ctx = canvas.getContext '2d'

                img = new node_canvas.Image
                img.src = buff
                ctx.drawImage img, 0, 0, width, height
                


                for line,i in theme_template.lines
                  h = Math.round(line.h/100*height)
                  x = line.x/100*width
                  y = line.y/100*height
                  w = line.w/100*width
                  ctx.fillStyle = hex_to_rgba line.color
                  ctx.font = h + 'px "' + line.font_family + '"'
                  if line.text_align is 'left'
                    ctx.fillText order.values[i].replace(/&nbsp;/g, ' ').replace(/\n/g, ''), x, y+h
                  else
                    measure = ctx.measureText order.values[i].replace(/&nbsp;/g, ' ').replace(/\n/g, ''), x, y+h
                    if line.text_align is 'right'
                      ctx.fillText order.values[i].replace(/&nbsp;/g, ' ').replace(/\n/g, ''), x+w-measure.width, y+h
                    if line.text_align is 'center'
                      ctx.fillText order.values[i].replace(/&nbsp;/g, ' ').replace(/\n/g, ''), x+(w-measure.width)/2, y+h



                alpha = Math.round(theme_template.qr.color2_alpha * 255).toString 16
                #
                qr_canvas = qr_code.draw_qr
                  node_canvas: node_canvas
                  style: 'round'
                  url: url
                  hex: theme_template.qr.color1
                  hex_2: theme_template.qr.color2+alpha
                #
                #
                #
                qr_canvas.toBuffer (err, qr_buff) ->
                  qr_img = new node_canvas.Image
                  qr_img.src = qr_buff


                  ctx.drawImage qr_img, theme_template.qr.x/100*width,theme_template.qr.y/100*height, theme_template.qr.w/100*width, theme_template.qr.h/100*height
                  
                  
                  canvas.toBuffer (err, buff) ->
                    res.send buff,
                      'Content-Type': 'image/png'
                    , 200
              else
                image_err res
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
# cards Page Mockup
app.get '/cards', securedPage, get_url_groups, (req, res) ->
  res.render 'cards'
    req: req
    thankyou: false
#
# cards Page Mockup
app.get '/cards/thank-you', securedPage, get_url_groups, (req, res) ->
  res.render 'cards'
    req: req
    thankyou: true
    abtest: 14
#
# Orders Page
app.get '/orders', securedAdminPage, (req, res, next) ->
  mongo_order.find
    'charge.paid': true
    'status':
      '$ne': 'Shipped'
  , (err, orders) ->
    req.orders = orders
    if check_no_err err, res
      res.render 'orders'
        req: req
        scripts:[
          'orders'
        ]
#
# Admin Page Mockup
app.get '/admin', securedAdminPage, (req, res, next) ->
  res.render 'admin'
    req: req
    scripts:[
      'libs/colorpicker.js'
      'admin'
    ]
#
# Make me an admin
app.get '/make-me-admin', securedPage, (req, res) ->
  req.user.role = 'admin'
  req.user.save (err) ->
    log_err err if err
    res.send '',
      Location: '/admin'
    , 302
#
#
# login page
app.get '/login', (req, res) ->
  #
  if req.user
    res.send '',
      Location: '/cards'
    , 302
  else
    res.render 'login'
      req: req
#
# About Page
app.get '/about', (req, res) ->
  res.render 'about'
    req: req
#
# How it Works Page
app.get '/how-QR-code-business-cards-work/:whateverComesAfterHowItWorks?', (req, res) ->
  res.render 'how_it_works'
    req: req
    whateverComesAfterHowItWorks: req.params.whateverComesAfterHowItWorks 
#
# Settings Page
app.get '/settings', get_order_info, securedPage, (req, res) ->
  res.render 'settings'
    req: req
    scripts:[
      'settings'
    ]
#

# Forgot Password
app.get '/forgot-password', (req, res) ->
  res.render 'forgot_password'
    req: req
    scripts:[
      'forgot'
    ]
    
# Password Reset
app.get '/reset-password/:password_reset_id', (req, res) ->
  res.render 'reset_password'
    req: req
    scripts:[
      'reset_password'
    ]

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
#
#
#
#
app.get '/buy', get_url_groups, (req, res, next) ->
  session = req.session
  if req.user
    if (session and session.saved_form and session.saved_form.values and session.saved_form.values.length > 0 and session.saved_form.values[0] is "John Stamos") or !session or !session.saved_form or !session.saved_form.values or !session.saved_form.values.length
      mongo_order.find
        user_id: req.user._id
      ,[],
        limit: 1
        sort:
          date_added: -1
      , (err, found_order) ->
        if err
          log_err err
        else
          if found_order.length and found_order[0].values and found_order[0].address and found_order[0].city and found_order[0].full_address
            req.session.saved_form.values = found_order[0].values
            req.session.saved_address =
              address: found_order[0].address
              city: found_order[0].city
              full_address: found_order[0].full_address
        next()
    else
      next()
  else
    next()
, (req, res, next) ->
  res.render 'order_form'
    req: req
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    # Uncomment the following line to add a custom h1 tag!
    #h1: 'some other h1 tag'
    #
    # (Uncomment means remove the single # character at the start of it :)
    #
    url_groups: req.url_groups
#
#
#
#
app.get '/phx', (req, res) ->
  res.render 'phx'
    req: req
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Welcome Phoenix Networkers!'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    # Uncomment the following line to add a custom h1 tag!
    h1: '<span>QR code business cards for Phoenix</span>'
    #
    # (Uncomment means remove the single # character at the start of it :)\
#
#
#
#
app.get '/sample-landing-page', (req, res) ->
  res.render 'sample_landing_page'
    req: req
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    # Uncomment the following line to add a custom h1 tag!
    #h1: 'some other h1 tag'
    #
    # (Uncomment means remove the single # character at the start of it :)
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
#
# Real Index Page
app.get '/', get_url_groups, (req, res) -> 
  #
  #
  if req.user
    res.send '',
      Location: '/cards'
    , 302
  else
    #
    #
    ua_string = req.header('USER-AGENT')
    ua = ua_match ua_string

    if (ua.browser is 'msie' and parseInt(ua.version, 10) < 9) or ua_string.match /mobile/i
      res.render 'simple_home'
        req: req
        #
        # Cut off at 60 characters 
        #
        title: 'Cardsly | Create and buy QR code business cards you control'
        # Cut off at 140 to 150 characters
        #
        description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
        #
        # Uncomment the following line to add a custom h1 tag!
        #h1: 'some other h1 tag'
        #
        # (Uncomment means remove the single # character at the start of it :)
        #
        url_groups: req.url_groups
    else
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
        #h1: 'some other h1 tag'
        #
        # (Uncomment means remove the single # character at the start of it :)
        #
        url_groups: req.url_groups
        #
        #
        scripts:[
          'home'
        ]
#
#
#
#
# The testing route I printed on my cards - DB
app.get '/beepBoop10', (req, res) ->
  urls = [
    'http://facebook.com/elforko'
    'http://twitter.com/elspoono'
    'http://blog.cards.ly'
    'http://elspoono.wordpress.com'
    'http://www.meetup.com/webdesignersdevelopers/members/8256239/'
    'http://www.slideshare.net/elspoono'
    'https://plus.google.com/100278450741153543517/posts'
    'http://github.com/elspoono'
  ]

  url = urls[Math.round(mrg.generate_real()*(urls.length-1))]
  res.send '',
    Location: url
  , 302
#
#
#
#
app.get '/make', (req, res, next) ->
  res.render 'make'
    req: req
    #
    # Cut off at 60 characters 
    #
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    #
    description: 'Design and create your own QR code business cards. See analytics and update links anytime in the Cardsly dashboard.'
    #
    # Uncomment the following line to add a custom h1 tag!
    #h1: 'some other h1 tag'
    #
    # (Uncomment means remove the single # character at the start of it :)
    #
#
#
#
#
#
#
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
# ### Start server
app.listen process.env.PORT || process.env.C9_PORT || 4000
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