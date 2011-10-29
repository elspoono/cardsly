
###
GENERIC LIBRARY LOADING AND SETUP
*****************************************

Express / Sendgrid / Coffeescript /  Imagemagick / etc etc etc

*****************************************
###


# Create server and export `app` as a module for other modules to require as a dependency 
# early in this file
express = require "express"
app = module.exports = express.createServer()
# Module requires
conf = require './lib/conf'

# Image Magick for graphic editing
im = require 'imagemagick'



geo = require('geo')

require 'coffee-script'
PDFDocument = require 'pdfkit'

nodemailer = require 'nodemailer'

nodemailer.SMTP = 
  host: 'smtp.sendgrid.net'
  port: 25
  use_authentication: true
  user: process.env.SENDGRID_USERNAME
  pass: process.env.SENDGRID_PASSWORD
  domain: process.env.SENDGRID_DOMAIN



# DATABASE
# url set
db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/staging'
url = require 'url' 
# parse the url
parsed = url.parse db_uri
mongodb = require 'mongodb'
dbAuth = {}
if parsed.auth
  auth = parsed.auth.split(':', 2)
  dbAuth.username = auth[0]
  dbAuth.password = auth[1]
Db = mongodb.Db
Server = mongodb.Server
db = new Db(parsed.pathname.replace(/^\//, ''), new Server(parsed.hostname, parsed.port))
# This library is for the database store for the session
mongoStore = require 'connect-mongodb'

# Mongoose is for everyone 
mongoose = require 'mongoose'
mongoose.connect db_uri
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

# This store is for the session
sessionStore = new mongoStore
  db: db
  username: dbAuth.username
  password: dbAuth.password

###
UTIL

it's a useful for inspecting.

USAGE:

console.log util.inspect myVariableIWantToInspect

###
util = require 'util'


# BCRYPT for password storage
bcrypt = require 'bcrypt'
encrypted = (inString) ->
  salt = bcrypt.gen_salt_sync(10)
  bcrypt.encrypt_sync(inString, salt)
compareEncrypted = (inString,hash) ->
  bcrypt.compare_sync(inString, hash)

# Everyauth for 3rd party providers
everyauth = require 'everyauth'
Promise = everyauth.Promise



###
DATABASE MODELING
*****************************************

All our schemas

*****************************************
###


# User Schema Definition
UserSchema = new Schema
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
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true

# User Authentication
UserSchema.static 'authenticate', (email, password, next) ->
  this.find
    email: email
    active:true
  , (err,data) ->
    if err
      next 'Database Error'
    else
      if data.length > 0
        if compareEncrypted password, data[0].password_encrypted
          next null, data[0]
        else
          next 'Password incorrect.'
      else
        next 'Email not found.'

# Actually build the User Model we just created
User = mongoose.model 'User', UserSchema


# Cards
CardSchema = new Schema
  user_id: Number
  print_id: Number
  path: String
  template_id: Number
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
Card = mongoose.model 'Card', CardSchema


# Images
ImageSchema = new Schema
  height: Number
  width: Number
  buffer: String
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
Image = mongoose.model 'Image', ImageSchema

# Messages
MessageSchema = new Schema
  include_contact: Boolean
  content: String
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
Message = mongoose.model 'Message', MessageSchema



# Templates
TemplateSchema = new Schema
  date_added:
    type: Date
    default: Date.now
  active:
    type: Boolean
    default: true
Template = mongoose.model 'Template', TemplateSchema

# Template Themes
ThemeSchema = new Schema
  template_id: Number
  thumb_image_id: Number
  preview_image_id: Number
  big_image_id: Number
  qr_size: Number
  qr_x: Number
  qr_y: Number
Theme = mongoose.model 'Theme', ThemeSchema

# TemplateTheme Field Positions
PositionSchema = new Schema
  theme_id: Number
  order_id: Number
  font_size: Number
  x: Number
  y: Number
Position = mongoose.model 'Position', PositionSchema

# Views (for stats)
ViewSchema = new Schema
  ip_address: String
  user_agent: String
  card_id: Number
  date_added:
    type: Date
    default: Date.now
View = mongoose.model 'View', ViewSchema






###
EVERYAUTH STUFF
*****************************************

Authenticating to 3rd Party Providers

*****************************************
###


# Handle Good Response
#
# Set up a response handler for all of the everyauth configs we are about to use
# Every one of those everyauth guys down below will call this
# 
# This should create the user or grab it based on the auth info
#
handleGoodResponse = (session, accessToken, accessTokenSecret, userMeta) ->
  #console.log 'userMeta', userMeta
  promise = new Promise()



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

  User.findOne userSearch, (err,user) ->
    if err
      console.log 'err: ', err
      promise.fail err
    else if user
      console.log 'user exists: ', user
      promise.fulfill
        user: user
    else
      user = new User
      user.name = userSearch.name
      user.linkedin_url = userSearch.linkedin_url
      user.facebook_url = userSearch.facebook_url
      user.twitter_url = userSearch.twitter_url
      user.email = userSearch.email
      user.save (err, user) -> 
        if err
          console.log 'err: ', err
          promise.fail err
        else
          console.log 'user created: ', user
          promise.fulfill
            user: user
  promise


###

Create the Everyauth Accessing the user function

per the "Accessing the user" section of the everyauth README

###

everyauth.everymodule.findUserById (userId, callback) ->
  User.findById userId, callback

# Twitter API Key and Config
everyauth.twitter.consumerKey 'I4s77xbnJvV0bHa7wO8zTA'
everyauth.twitter.consumerSecret '7JjalH7ZVkExJumLIDwsc8BkgxGoaxtSlipPmChY0'
everyauth.twitter.findOrCreateUser handleGoodResponse
everyauth.twitter.redirectPath '/success'

# Facebook API Key / Config
everyauth.facebook.appId '292309860797409'
everyauth.facebook.appSecret '70bcb1477ede9a706e285f7faafa8e32'
everyauth.facebook.findOrCreateUser handleGoodResponse
everyauth.facebook.redirectPath '/success'

# LinkedIn API Key / Config
everyauth.linkedin.consumerKey 'fuj9rhx302d7'
everyauth.linkedin.consumerSecret 'pvWmN5CkrdT3GHF3'
everyauth.linkedin.findOrCreateUser handleGoodResponse
everyauth.linkedin.redirectPath '/success'

# Google API Key / Config
everyauth.google.appId '90634622438.apps.googleusercontent.com'
everyauth.google.appSecret 'Bvpnj5wXiakpkOnwmXyy4vDj'
everyauth.google.findOrCreateUser handleGoodResponse
everyauth.google.scope 'https://www.googleapis.com/auth/userinfo.email'
everyauth.google.redirectPath '/success'

# Google API requires additional setup to use 
rest = require('./node_modules/everyauth/node_modules/restler');
everyauth.google.fetchOAuthUser (accessToken) ->
  promise = this.Promise()
  rest.get 'https://www.googleapis.com/userinfo/email', 
    query:
      oauth_token: accessToken
      alt: 'json'
  .on 'success',(data, res) ->
    oauthUser = 
      email: data.data.email
    promise.fulfill oauthUser
  .on 'error', (data, res) ->
    promise.fail data
  promise;



###
everyauth.googlehybrid.consumerKey 'cards.ly'
everyauth.googlehybrid.consumerSecret 'C_UrIqmFopTXRPLFfFRcwXa9'
everyauth.googlehybrid.findOrCreateUser handleGoodResponse
everyauth.googlehybrid.scope ['email']
everyauth.googlehybrid.redirectPath '/success'
###
everyauth.debug = true








# ## App configurations
# ### Global app settings
#
# **Note**: Notice that we got our session secret from the configuration file. In this file
# we can define our configurations as globals or based on the node environment, thus 
# keeping all the configurable variables centralized instead of being scattered all over.
app.configure ->
  app.set "views", __dirname + conf.dir.views
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: conf.sessionSecret
    store: sessionStore #
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

###
ROUTES

All of our routes are defined here

###

# Redirect Error
err = (res, err) ->
  res.send '',
    Location: '/error'
  , 302


# Home Page
app.get '/', (req, res) ->
  res.render 'index'

# Success Page
#
# Where they land after authenticating
# This should close automatically or redirect to the home page if no caller
app.get '/success', (req, res) ->
  res.render 'success'
    user: req.user

# Cards Page Mockup
app.get '/cards', (req, res) ->
  res.render 'cards'


# About Page
app.get '/about', (req, res) ->
  res.render 'about'

# Generic Error handler page itself
app.get '/error', (req, res) ->
  res.render 'error'

# Robots.txt to tell google it's cool to crawl
app.get '/robots.txt', (req, res, next) ->
  res.send 'User-agent: *\nDisallow: ',
    'Content-Type': 'text/plain'


# Default Route
#
# Redirect everything to the home page automagically
app.get /^(?!(\/favicon.ico|\/images|\/js|\/css)).*$/, (req, res, next) ->
  res.send '',
    Location:'/'
  , 301


# ### Start server
app.listen process.env.PORT || process.env.C9_PORT || 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
