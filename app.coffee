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
#
process.on 'uncaughtException', (err) ->
  console.log 'UNCAUGHT', err
#
# Create server and export `app` as a module for other modules to require as a dependency 
# early in this file
express = require 'express'
http = require 'http'
form = require 'connect-form'
knox = require 'knox'
util = require 'util'
fs = require 'fs'
app = module.exports = express.createServer()
#
# Image Magick for graphic editing
im = require 'imagemagick'
#
#
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
#PDFDocument = require 'pdfkit'
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
  ###
  payment_method:
    token: String
    card_type: String
    last_four_digits: String
    expiry_month: String
    expiry_year: String
  ###
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
  theme_id: Number
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
    radius: Number
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
  category: String
  theme_templates: [theme_template_schema]
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
#
#
#
small_url_schema = new schema
  url_string: String
  card_number: String
  redirect_to: String
#
#
url_group_schema = new schema
  user_id: String
  order_id: String
  urls: [small_url_schema]
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
# Views (for stats)
view_schema = new schema
  ip_address: String
  user_agent: String
  card_id: String
  date_added:
    type: Date
    default: Date.now
mongo_view = mongoose.model 'views', view_schema
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
      console.log 'ERR: ', err
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
          console.log 'ERR: ', err
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



request = require 'request'

# Variables we'll re-use
customer_questions_available = true
customer_questions_last_checked = 0

# The checking function
is_customer_questions_available = ->
  if customer_questions_last_checked < (new Date() - 1000*60)
    request 'https://9fc02ebc1276b9a8b87e0fff796d5e29d7ab61f5:X@jodesco.campfirenow.com/room/455425.json', (err, res, body) ->
      if err or res.statusCode isnt 200
        console.log 'ERR: campfire no response? - ', err
      else
        result = JSON.parse body
        customer_questions_last_checked = new Date()
        customer_questions_available = false
        for user in result.room.users
          if user.type is 'Member'
            customer_questions_available = true
  customer_questions_available











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
    is_customer_questions_available: is_customer_questions_available
    #
    # Cut off at 60 characters 
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    #
  app.use form
    keepExtensions: true
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
  ['a',8]
  ['o',7]
  ['i',7]
  ['u',3]
  ['y',2]
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
  ['qu',1]
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
numbers = ['',1,2,3,4,5,6,7,8,9]
random_url = () ->
  psuedo = ''
  c_l = consonants.length - 1
  v_l = vowels.length - 1
  n_l = numbers.length - 1
  add_number = ->
    for i in [0..1]
      psuedo += numbers[Math.round(mrg.generate_real()*n_l)]
    if Math.round(mrg.generate_real())
      psuedo += 0
  add_consonant_upper = ->
    for i in [0..0]
      consonant = consonants[Math.round(mrg.generate_real()*c_l)]
      if Math.round(mrg.generate_real())
        psuedo += consonant
      else
        psuedo += consonant.toUpperCase()
  add_vowel = ->
    for i in [0..0]
      vowel = vowels[Math.round(mrg.generate_real()*v_l)]
      psuedo += vowel
      if Math.round(mrg.generate_real())
        psuedo += vowel
  add_consonant = ->
    for i in [0..0]
      psuedo += consonants[Math.round(mrg.generate_real()*c_l)]
  add_consonant_upper()
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
#
#
# Form request for multipart form uploading image
app.post '/upload-image', (req, res) ->
  #
  # Set up our failure function
  s3_fail = (err) ->
    console.log 'ERR: ', err
    res.send '<script>parent.window.$.s3_result(false);</script>'
  #
  try
    # Wait for the upload of the large file to finish before doing anything
    req.form.complete (err, fields, files) ->
      if err
        s3_fail err
      else
        # Find the file we just created
        path = files.image.path
        # Identify it's filname
        fileName = path.replace /.*tmp\//ig, ''
        # And it's extension
        ext = fileName.replace /.*\./ig, ''

        # Define the sizes we will resize too
        sizes = [
          '158x90'
          '525x300'
        ]
        for size in sizes
          do (size) ->
            # Resize it with ImageMagick
            im.convert [
              path
              '-filter','Quadratic'
              '-resize',size
              '/tmp/'+size+fileName
            ], (err, smallImg, stderr) ->
              if err
                s3_fail err
              else
                # Read the resized File with node FS libary
                fs.readFile '/tmp/'+size+fileName, (err, buff) ->
                  if err
                    console.log 'ERR:', err
                  else
                    # Send that new file to Amazon to be saved!
                    knoxReq = knoxClient.put '/'+size+'/'+fileName,
                      'Content-Length': buff.length
                      'Content-Type' : 'image/'+ext
                    knoxReq.on 'response', (awsRes) ->
                      console.log 'ERR', awsRes if awsRes.statusCode != 200
                      # Only send this response once we get the 525x300 that we need
                      if size is '525x300'
                        if awsRes.statusCode is 200
                          res.send '<script>parent.window.$.s3_result(\'' + fileName + '\');</script>'
                        else
                          s3_fail awsRes
                    knoxReq.end buff
                    # Finally, delete that temporary resized file. Keep shit clean.
                    fs.unlink '/tmp/'+size+fileName, (err) ->
                      if err
                        console.log 'ERR:', err
        
        # Read the raw File
        fs.readFile path, (err, buff) ->
          # Send that raw file to Amazon to be saved!
          knoxReq = knoxClient.put '/raw/'+fileName,
            'Content-Length': buff.length
            'Content-Type' : 'image/'+ext
          knoxReq.on 'response', (res) ->
            console.log 'ERR', res if res.statusCode != 200
          knoxReq.end buff
  catch err
    s3_fail err
#
#
#
#
#
#
# Generic Ajax Error Handling
check_no_err_ajax = (err) ->
  if err
    console.log 'ERR: ', err
    res.send
      err: err
  !err
#
#
# AJAX request for saving theme
#
app.post '/save-theme', (req, res) ->
  #
  # Put it into a nice pretty JSON object 
  params = req.body
  #
  # Save it in the session always.
  req.session.theme = params.theme
  #
  #
  # If we hit the save button
  if params.do_save
    #
    # If we're updating do this
    if params.theme._id
      mongo_theme.findById params.theme._id, (err, found_theme) ->
        if check_no_err_ajax err
          found_theme.category
          found_theme.date_updated = new Date()
          if typeof(params.theme.active) is 'boolean'
            found_theme.active = params.theme.active
          found_theme.category = params.theme.category
          #
          # Push the new template in
          found_theme.theme_templates = params.theme.theme_templates
          #
          #
          found_theme.save (err,theme_saved) ->
            if check_no_err_ajax err
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
      #
      # Push the new template in
      new_theme.theme_templates = params.theme.theme_templates
      #
      #
      new_theme.save (err,theme_saved) ->
        if check_no_err_ajax err
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
      console.log 'ERR: Feedback Email did not send - ', err, req.body.email, req.body.content
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
          if check_no_err_ajax err
            res.send
              success: true
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
    ###
    payment_method:
      card_type: req.user.payment_method.card_type
      last_four_digits: req.user.payment_method.last_four_digits
      expiry_month: req.user.payment_method.expiry_month
      expiry_year: req.user.payment_method.expiry_year
    ###

#
#
#
#
# Get Themes (post route for get themes :)
app.post '/get-themes', (req,res,next) ->
  mongo_theme.find
    active: true
  ,[] ,
    sort:
      date_updated: 0
  , (err, themes) ->
    if check_no_err_ajax err
      res.send
        themes: themes
#
#
#
add_urls_to_order = (order, user) ->
  #
  #
  #
  redirect_to = 'http://cards.ly/'+order.order_number
  #
  # Generate order urls, based on "quantity" (which isnt really quantity)
  #
  volume = 100
  volume = 250 if order.quantity*1 is 25
  volume = 500 if order.quantity*1 is 35
  volume = 1500 if order.quantity*1 is 70
  #
  #
  #
  ###
  mongo_theme.findById order.theme_id, (err, theme) ->
    console.log theme
  ###
  #
  create_urls
    redirect_to: redirect_to
    volume: volume
  , (err, new_urls) ->

    url_group = new mongo_url_group
    url_group.order_id = order._id
    url_group.user_id = user._id
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
        console.log 'ERR: saving group - ', err
    #
    #
    user.save (err, saved_user) ->
      if err
        console.log 'ERR: saving user - ', err
  volume
  #
#
#
app.get '/add-test', (req, res, next) ->
  mongo_order.findOne
    user_id: req.user._id
  , (err, order) ->
    add_urls_to_order order, req.user
    res.send 'Done'
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
  order.status = 'Pending'
  order.quantity = req.session.saved_form.quantity
  order.shipping_method = req.session.saved_form.shipping_method
  order.values = req.session.saved_form.values
  order.address = req.session.saved_address.address
  order.city = req.session.saved_address.city
  order.full_address = req.session.saved_address.full_address
  order.amount = (req.session.saved_form.quantity*1 + req.session.saved_form.shipping_method*1) * 100
  order.email = req.body.email
  order.shipping_email = req.body.shipping_email
  order.confirm_email = req.body.confirm_email
  order.save (err, new_order) ->
    if check_no_err_ajax err
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
            console.log 'ERR: stripe customer create resulted in ', err, customer
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
                console.log 'ERR: database ', err
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
      if check_no_err_ajax err
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
            console.log 'ERR: database ', err
        #
        #
        #
        if err
          console.log 'ERR: stripe charge resulted in ', err
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
          #
          volume = add_urls_to_order new_order, req.user
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
          if new_order.confirm_email and new_order.email
            nodemailer.send_mail
              sender: 'help@cards.ly'
              to: new_order.email
              subject: 'Cardsly Order Confirmation - Order ID: ' + new_order.order_number
              html: message
            , (err, data) ->
              if err
                console.log 'ERR: Confirm email did not send - ', err, new_order.order_number
          #
          # Send us an email
          nodemailer.send_mail
            sender: 'support@cards.ly'
            to: 'help@cards.ly'
            subject: 'Cardsly Order Received - Order ID: ' + new_order.order_number
            html: '<p>A new order was received!</p><blockquote>' + message + '</blockquote>'
          , (err, data) ->
            if err
              console.log 'ERR: Notification email did not send - ', err, new_order.order_number
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
  else if req.session.saved_form.values[0] is "John Stamos"
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
  result = req.result
  res.render 'path_you_want'
    user: req.user
    session: req.session
    result: result

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
    console.log err
    res.send '',
      Location: '/error'
    ,302
  !err
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
get_url_groups = (req, res, next) ->
  if req.user
    mongo_url_group.find
      user_id: req.user._id
    , (err, url_groups) ->
      if check_no_err err
        #
        #
        req.url_groups = url_groups
        #
        #
        next()
  else
    next()
#
# cards Page Mockup
app.get '/cards', securedPage, get_order_info, get_url_groups, (req, res) ->
  res.render 'cards'
    orders: req.orders
    user: req.user
    session: req.session
    url_groups: req.url_groups
    thankyou: false
#
# cards Page Mockup
app.get '/cards/thank-you', securedPage, get_order_info, get_url_groups, (req, res) ->
  res.render 'cards'
    orders: req.orders
    user: req.user
    session: req.session
    url_groups: req.url_groups
    thankyou: true
#
# Orders Page
app.get '/orders', securedAdminPage, (req, res, next) ->
  mongo_order.find
    'charge.paid': true
  , (err, orders) ->
    if check_no_err err, res
      res.render 'orders'
        user: req.user
        orders: orders
        session: req.session
        scripts:[
          'orders'
        ]
#
# Admin Page Mockup
app.get '/admin', securedAdminPage, (req, res, next) ->
  res.render 'admin'
    user: req.user
    session: req.session
    scripts:[
      'libs/colorpicker.js'
      'admin'
    ]
#
# Make me an admin
app.get '/make-me-admin', securedPage, (req, res) ->
  req.user.role = 'admin'
  req.user.save (err) ->
    console.log err if err
    res.send '',
      Location: '/admin'
    , 302
#
#
# login page
app.get '/login', (req, res) ->
  res.render 'login'
    user: req.user
    session: req.session
#
# About Page
app.get '/about', (req, res) ->
  res.render 'about'
    user: req.user
    session: req.session
#
# How it Works Page
app.get '/how-it-works/:whateverComesAfterHowItWorks?', (req, res) ->
  res.render 'how_it_works'
    user: req.user
    session: req.session
    whateverComesAfterHowItWorks: req.params.whateverComesAfterHowItWorks 
#
# Settings Page
app.get '/settings', securedPage, (req, res) ->
  res.render 'settings'
    user: req.user
    session: req.session
    scripts:[
      'settings'
    ]
#
# Splash Page
app.get '/old-browser', (req, res) -> 
  res.render 'old_browser'
    user: req.user
    session: req.session
    layout: 'layout_min'
#
# Error Page
app.get '/error', (req, res) -> 
  res.render 'error'
    user: req.user
    session: req.session
    layout: 'layout_min'

# Cute Animal PAges
app.get '/cute-animal', (req, res) -> 
  res.render 'cute_animal'
    user: req.user
    session: req.session
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
          console.log err
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
    user: req.user
    session: req.session
    #
    # Cut off at 60 characters 
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    url_groups: req.url_groups
#
#
#
#
app.get '/sample-landing-page', get_url_groups, (req, res) ->
  res.render 'sample_landing_page'
    user: req.user
    session: req.session
    #
    # Cut off at 60 characters 
    title: 'Cardsly | Create and buy QR code business cards you control'
    # Cut off at 140 to 150 characters
    description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
    #
    url_groups: req.url_groups
#
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
        user: req.user
        session: req.session
        #
        # Cut off at 60 characters 
        title: 'Cardsly | Create and buy QR code business cards you control'
        # Cut off at 140 to 150 characters
        description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
        #
        url_groups: req.url_groups
    else
      res.render 'home'
        user: req.user
        session: req.session
        #
        # Cut off at 60 characters 
        title: 'Cardsly | Create and buy QR code business cards you control'
        # Cut off at 140 to 150 characters
        description: 'Design and create your own business cards with qr codes. See analytics and update links anytime in the Cardsly dashboard.'
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
    user: req.user
    session: req.session
    #
    # Cut off at 60 characters 
    title: 'Cardsly | Generate custom QR Code images with short urls'
    # Cut off at 140 to 150 characters
    description: 'Create your own custom designed qr code images with short urls. See analytics and update links anytime in the Cardsly dashboard.'
    #
#
#
#
#
qr_code = require('./assets/js/libs/qrcode.js')
_ = require 'underscore'
node_canvas = require 'canvas'
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

ctx_inverted_arc = (my_ctx, a, b, c, d) ->
  my_ctx.beginPath()
  my_ctx.moveTo c, b
  my_ctx.quadraticCurveTo a, b, a, d
  my_ctx.lineTo a, b
  my_ctx.lineTo c, b
  my_ctx.fill()
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
    params.url = req.url.replace /^[^\?]*\?/i, ''
  

  if req.params.color
    if req.params.color.match /[a-f0-9]{6,8}/i
      params.hex = req.params.color
    else
      req.params.style = req.params.color

  if req.params.color_2
    if req.params.color_2.match /[a-f0-9]{6,8}/i
      params.hex_2 = req.params.color_2
    else
      req.params.style = req.params.color
  

  if req.params.style
    if req.params.style is 'circle'
      params.style = req.params.style
      params.round = 4
    if req.params.style is 'square'
      params.style = req.params.style
      params.round = 0
    if req.params.style is 'round'
      params.style = req.params.style
      params.round = 5

  qr = qr_code.create params.url



  count = qr.moduleCount
  factor = 2
  #
  scale = 10 * factor
  offset = 0 * factor
  qr_border_offset = 20 * factor
  border_offset = 10 * factor
  round = params.round * factor
  #
  quarter = scale/2
  #
  size = count * border_offset + qr_border_offset * 2


  canvas = new node_canvas(size,size)
  ctx = canvas.getContext '2d'

  ctx.fillStyle = hex_to_rgba params.hex

  #

  if params.hex_2 isnt 'transparent'
    
    ctx.fillStyle = hex_to_rgba params.hex_2
    
    if params.style is 'square'
      ctx.fillRect 0, 0, size, size
    else
      ctx.beginPath()
      ctx.moveTo qr_border_offset, 0
      ctx.lineTo size-qr_border_offset, 0
      ctx.quadraticCurveTo size, 0, size, qr_border_offset
      ctx.lineTo size, size-qr_border_offset
      ctx.quadraticCurveTo size, size, size-qr_border_offset, size
      ctx.lineTo qr_border_offset, size
      ctx.quadraticCurveTo 0, size, 0, size-qr_border_offset
      ctx.lineTo 0, qr_border_offset
      ctx.quadraticCurveTo 0, 0, qr_border_offset, 0
      ctx.fill()

    ctx.fillStyle = hex_to_rgba params.hex


  for r in [0..count-1]
    for c in [0..count-1]
      
      #
      # r is the row we are on
      # ... and c is the column
      #
      # x and y are the top left starting points for our qr grid item
      #
      # scale is the size of the grid item
      #
      # params.style is the type of drawing we are doing for that grid item

      x = c*border_offset+qr_border_offset+offset
      y = r*border_offset+qr_border_offset+offset
        
      if qr.isDark r,c
        #
        #
        #
        if params.style is 'square'
          ctx.fillRect x, y, scale, scale
        #
        #
        if params.style is 'circle'
          ctx.beginPath()
          ctx.arc x+quarter, y+quarter, quarter+1, 0, Math.PI*2
          ctx.fill()
        #
        #
        if params.style is 'round'
          #
          ctx.beginPath()
          #
          # top middle
          ctx.moveTo x+quarter, y

          # top right
          if qr.isDark(r,c+1) or qr.isDark(r-1,c)
            ctx.lineTo x+scale, y
          else
            ctx.lineTo x+scale-round, y
            ctx.quadraticCurveTo x+scale, y, x+scale, y+round

          # bottom right
          if qr.isDark(r,c+1) or qr.isDark(r+1,c)
            ctx.lineTo x+scale, y+scale
          else
            ctx.lineTo x+scale, y+scale-round
            ctx.quadraticCurveTo x+scale, y+scale, x+scale-round, y+scale

          # bottom left
          if qr.isDark(r,c-1) or qr.isDark(r+1,c)
            ctx.lineTo x, y+scale
          else
            ctx.lineTo x+round, y+scale
            ctx.quadraticCurveTo x, y+scale, x, y+scale-round

          # top left
          if qr.isDark(r,c-1) or qr.isDark(r-1,c)
            ctx.lineTo x, y
          else
            ctx.lineTo x, y+round
            ctx.quadraticCurveTo x, y, x+round, y
          

          # return to top middle
          ctx.lineTo x+quarter, y

          # fill it all in
          ctx.fill()
          #
          #
      else
        if params.style is 'round'
          #
          # top left
          if qr.isDark(r-1,c-1) and qr.isDark(r-1,c) and qr.isDark(r,c-1)
            ctx_inverted_arc ctx, x, y, x+quarter/2, y+quarter/2
          #
          # top right
          if qr.isDark(r-1,c) and qr.isDark(r-1,c+1) and qr.isDark(r,c+1)
            ctx_inverted_arc ctx, x+scale, y, x+scale-quarter/2, y+quarter/2
          #
          # bottom right
          if qr.isDark(r,c+1) and qr.isDark(r+1,c+1) and qr.isDark(r+1,c)
            ctx_inverted_arc ctx, x+scale, y+scale, x+scale-quarter/2, y+scale-quarter/2
          #
          # bottom left
          if qr.isDark(r,c-1) and qr.isDark(r+1,c-1) and qr.isDark(r+1,c)
            ctx_inverted_arc ctx, x, y+scale, x+quarter/2, y+scale-quarter/2

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