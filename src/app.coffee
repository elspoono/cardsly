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
# Module requires
conf = require './lib/conf'
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
  email:String
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
  custom_1: String
  custom_2: String
  custom_3: String
  payment_method:
    token: String
    card_type: String
    last_four_digits: String
    expiry_month: String
    expiry_year: String
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
  date_added:
    type: Date
    default: Date.now
#
mongo_order = mongoose.model 'orders', order_schema
#
#
url_schema = new schema
  url_string: String
  user_id: String
  redirect_to: String
#
mongo_url = mongoose.model 'urls', url_schema
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
  console.log userMeta
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
      console.log 'err: ', err
      promise.fail err
    else if existinguser
      console.log 'user exists: ', existinguser
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
          console.log 'err: ', err
          promise.fail err
        else
          console.log 'user created: ', createduser
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
everyauth.google.appId '90634622438.apps.googleusercontent.com'
everyauth.google.appSecret 'Bvpnj5wXiakpkOnwmXyy4vDj'
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













###
TODO

For middleware
- Make the session and user objects sent on every request sent automatically instead of being something we have to pass each time to the jade.

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
  app.set "views", __dirname + conf.dir.views
  app.set "view engine", "jade"
  app.set 'view options',
    scripts: []
    user: false
    session: false
    error_message: false
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
  app.use express.static(__dirname + conf.dir.public)
  app.use everyauth.middleware()


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
mrg = require(__dirname + '/mrg')
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
new_url = () ->
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
valid_new_url = (next) ->
  try_url = new_url()
  mongo_url.count
    url_string: try_url
  , (err, count) ->
    if err
      next err
    if not count
      next null, try_url
    else
      valid_new_url next
###
for i in [0..100]
  valid_new_url (err, url) ->
    if err
      console.log 'ERR: ', err
    else
      console.log url
###
#
#
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
    console.log err
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
    console.log full_address, latitude, longitude, details
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
      console.log req.user
#
#
#
#
# Sends feedback to us
app.post '/send-feedback', (req,res,next) ->
  res.send
      succesfulFeedback:'This worked!'
  nodemailer.send_mail
    sender: req.body.email
    to: 'support@cards.ly'
    cc: 'help@cards.ly'
    subject:'Feedback email from:' + req.body.email
    html: '<p>This is some feedback</p><p>' + req.body.content + '</p>'
  , (err, data) ->
    if err
      console.log 'ERR Feedback Email did not send:', err, req.body.email, req.body.content
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
  req.user.password_encrypted = encrypted(req.body.new_password);
  req.user.save (err,data) ->
    res.send
      success: 'True'
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
app.post '/validate-purchase', (req, res, next) ->
  console.log req.user
  console.log req.session
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
check_no_err = (err) ->
  if err
    console.log err
    res.send '',
      Location: '/error'
    ,302
  !err
#
#
#
# Home Page
app.get '/', (req, res) ->
  res.render 'landing-prelaunch'
    user: req.user
    session: req.session
    layout: 'layout_landing'
#
# Success Page
#
# Where they land after authenticating
# This should close automatically or redirect to the home page if no caller
app.get '/success', (req, res) ->
  res.render 'success'
    user: req.user
    session: req.session
#
# cards Page Mockup
app.get '/cards', securedPage, (req, res) ->
  res.render 'cards'
    user: req.user
    session: req.session
#
# Admin Page Mockup
app.get '/admin', securedAdminPage, (req, res, next) ->
  res.render 'admin'
    user: req.user
    session: req.session
    scripts:[
      '/js/libs/colorpicker/js/colorpicker.js'
      '/js/libs/excanvas.compiled.js'
      '/js/admin.js'
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
  res.render 'how-it-works'
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
      '/js/settings.js'
    ]
#
#
#
#
#
#Thank_You Page
app.get '/thank-you', (req, res) -> 
  #
  # First, we try to grab it from the url
  payment_method_token = req.query.payment_method_token
  #
  #
  # If it's not there, we try to grab it from the database
  if not payment_method_token and req.user and req.user.payment_method and req.user.payment_method.token
    payment_method_token = req.user.payment_method.token
  #
  #
  # And if we found it either place, then proceed
  if payment_method_token
    #
    #
    # Figure out their total
    total = (req.session.saved_form.quantity+req.session.saved_form.shipping_method) * 1
    #
    #
    # Hit up samurai for their payment_method details
    #
    samurai.PaymentMethod.find payment_method_token, (err, payment_method) ->
      if err
        # Do Error
        console.log 'ERR: ', err
        res.render 'order_form'
          error_message: 'Something went wrong. Please try again.'
          user: req.user
          session: req.session
      else
        #
        #
        console.log 'PAYMENT: ', payment_method
        #
        req.user.payment_method = 
          token: payment_method_token
          card_type: payment_method.attributes.card_type
          last_four_digits: payment_method.attributes.last_four_digits
          expiry_month: payment_method.attributes.expiry_month
          expiry_year: payment_method.attributes.expiry_year
        #
        #
        req.user.save (err, saved_user) ->
          if err
            # Do Error
            console.log 'ERR: ', err
            res.render 'order_form'
              error_message: 'Something went wrong. Please try again.'
              user: req.user
              session: req.session
          else
            #
            #
            #
            #
            # Try it
            samurai.Processor.purchase payment_method_token, total,
              billing_reference: 'Billing Reference'
              customer_reference: req.user._id
              custom: req.user.email or req.user.name
              descriptor: req.user.linkedin_url or req.user.facebook_url or req.user.twitter_url
            , (err, purchase) ->
              if err
                # Do Error
                console.log 'PURCHASE: ', purchase
                console.log 'ERR: ', err
                res.render 'order_form'
                  error_message: 'Something might be wrong with that credit card number or it\'s CVC number. I couldn\'t process it.'
                  user: req.user
                  session: req.session
              else
                if purchase.isSuccess()
                  valid_new_url (err, url) ->
                    if err
                      console.log 'ERR: ', err
                      res.render 'order_form'
                        error_message: 'Something went wrong. Please try again.'
                        user: req.user
                        session: req.session
                    else
                      order = new mongo_order
                      order.order_number = url
                      order.user_id = req.user._id
                      order.theme_id = session.saved_form.active_theme_id
                      order.status = 'Charged'
                      order.quantity = session.saved_form.quantity
                      order.shipping_method = session.saved_form.shipping_method
                      order.values = session.saved_form.values
                      order.address = session.saved_address.address
                      order.city = session.saved_address.city
                      order.full_address = session.saved_address.full_address
                      order.save (err, new_order) ->
                        if err
                          console.log 'ERR: ', err
                          res.render 'order_form'
                            error_message: 'Something went wrong. Please try again.'
                            user: req.user
                            session: req.session
                        else
                          res.render 'thank-you'
                            user: req.user
                            session: req.session
                else
                  console.log 'CARD ERR: ', purchase.messages
                  res.render 'order_form'
                    error_message: 'I\'m sorry, we couldn\'t process that credit card.'
                    user: req.user
                    session: req.session
    #
    # 
  else
    console.log 'ERR: ', 'Hit the thank you page without a token.'
    res.render 'order_form'
      error_message: 'Something went wrong. Please try again.'
      user: req.user
      session: req.session
    # Do Error
#
#
# Splash Page
app.get '/splash', (req, res) -> 
  res.render 'splash'
    user: req.user
    session: req.session
    layout: 'layout_landing'
#
# Error Page
app.get '/error', (req, res) -> 
  res.render 'error'
    user: req.user
    session: req.session
    layout: 'layout_landing'

# Cute Animal PAges
app.get '/cute-animal', (req, res) -> 
  res.render 'cute-animal'
    user: req.user
    session: req.session
    layout: 'layout_landing'
  

#
# Landing page prelaunch
app.get '/home', (req, res) -> 
  ua_string = req.header('USER-AGENT')
  ua = ua_match ua_string

  if ua.browser is 'msie' and parseInt(ua.version, 10) < 9
    res.render 'simple_home'
      user: req.user
      session: req.session
  else if ua_string.match /mobile/i
    res.render 'simple_home'
      user: req.user
      session: req.session
  else
    res.render 'index'
      user: req.user
      session: req.session
      scripts:[
        '/js/home.js'
      ]
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
  res.sendfile __dirname + '/public/js/libs/PIE.htc',
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