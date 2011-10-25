# Create server and export `app` as a module for other modules to require as a dependency 
# early in this file
express = require "express"
app = module.exports = express.createServer()

# Module requires
conf = require './lib/conf'


###
 Stuff we add to every app to setup sessions and mongo and mailing to work on heroku and locally
###

im = require 'imagemagick'

db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/staging'

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





url = require 'url' 
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
mongoStore = require 'connect-mongodb'

mongoose = require 'mongoose'
mongoose.connect db_uri
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

sessionStore = new mongoStore
  db: db
  username: dbAuth.username
  password: dbAuth.password

util = require 'util'

# BCRYPT for password storage
bcrypt = require 'bcrypt'
encrypted = (inString) ->
  salt = bcrypt.gen_salt_sync(10)
  bcrypt.encrypt_sync(inString, salt)
compareEncrypted = (inString,hash) ->
  bcrypt.compare_sync(inString, hash)

everyauth = require 'everyauth'
Promise = everyauth.Promise



# Redirect Error

err = (res, err) ->
  res.send '',
    Location: '/error'
  , 302


###
DATABASE SCHEMA
*****************************************

All our schemas

*****************************************
###


# User
UserSchema = new Schema
  email:String
  password_encrypted: String
  role: String
  name: String
  title: String
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
      err err
    else
      if data.length > 0
        if compareEncrypted password, data[0].password_encrypted
          next null, data[0]
        else
          next 'Password incorrect.'
      else
        next 'Email not found.'

# Assign the User Model
User = mongoose.model 'User', UserSchema

handleGoodResponse = (session, accessToken, accessTokenSecret, userMeta) ->
  #console.log 'userMeta', userMeta
  promise = new Promise()
  user = {}
  if userMeta.publicProfileUrl
    user.name = userMeta.firstName+' '+userMeta.lastName
    user.linkedin_url = userMeta.publicProfileUrl
  if userMeta.link
    user.name = userMeta.name
    user.facebook_url = userMeta.link
  if userMeta.screen_name
    user.name = userMeta.name
    user.twitter_url = 'http://twitter.com/#!'+userMeta.screen_name
  if userMeta.email
    user.email = userMeta.email

  console.log user

  promise.fulfill
    id: 'after finding or creating the user, this is it'
  promise

everyauth.twitter.consumerKey 'I4s77xbnJvV0bHa7wO8zTA'
everyauth.twitter.consumerSecret '7JjalH7ZVkExJumLIDwsc8BkgxGoaxtSlipPmChY0'
everyauth.twitter.findOrCreateUser handleGoodResponse
everyauth.twitter.redirectPath '/success'


everyauth.facebook.appId '292309860797409'
everyauth.facebook.appSecret '70bcb1477ede9a706e285f7faafa8e32'
everyauth.facebook.findOrCreateUser handleGoodResponse
everyauth.facebook.redirectPath '/success'


everyauth.linkedin.consumerKey 'fuj9rhx302d7'
everyauth.linkedin.consumerSecret 'pvWmN5CkrdT3GHF3'
everyauth.linkedin.findOrCreateUser handleGoodResponse
everyauth.linkedin.redirectPath '/success'

everyauth.google.appId '90634622438.apps.googleusercontent.com'
everyauth.google.appSecret 'Bvpnj5wXiakpkOnwmXyy4vDj'
everyauth.google.findOrCreateUser handleGoodResponse
everyauth.google.scope 'https://www.googleapis.com/auth/userinfo.email'
everyauth.google.redirectPath '/success'
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
    store: sessionStore
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

# ### Require routes


app.get '/', (req, res) ->
  res.render 'index'

app.get '/success', (req, res) ->
  res.render 'success'

app.get '/cards', (req, res) ->
  res.render 'cards'

app.get '/error', (req, res) ->
  res.render 'error'

app.get '/robots.txt', (req, res, next) ->
  res.send 'User-agent: *\nDisallow: ',
    'Content-Type': 'text/plain'

app.get /^(?!(\/favicon.ico|\/images|\/js|\/css)).*$/, (req, res, next) ->
  res.send '',
    Location:'/'
  , 301


# ### Start server
app.listen process.env.PORT || process.env.C9_PORT || 4000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
