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

# BCRYPT for password storage
bcrypt = require 'bcrypt'
encrypted = (inString) ->
  salt = bcrypt.gen_salt_sync(10)
  bcrypt.encrypt_sync(inString, salt)
compareEncrypted = (inString,hash) ->
  bcrypt.compare_sync(inString, hash)

everyauth = require 'everyauth'
Promise = everyauth.Promise

everyauth.twitter.consumerKey 'I4s77xbnJvV0bHa7wO8zTA'
everyauth.twitter.consumerSecret '7JjalH7ZVkExJumLIDwsc8BkgxGoaxtSlipPmChY0'
everyauth.twitter.findOrCreateUser (session, accessToken, accessTokenSecret, twitterUserMetadata) ->
  promise = new Promise()
  console.log twitterUserMetadata
  everyAuth.fulfull twitterUserMetadata
  promise
everyauth.twitter.redirectPath '/'

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
    script: 'home'
    title: 'KickbackCard - iPhone App Loyalty Card Program'



app.get '/robots.txt', (req, res, next) ->
  res.send 'User-agent: *\nDisallow: ',
    'Content-Type': 'text/plain'

app.get /^(?!(\/favicon.ico|\/images|\/js|\/css)).*$/, (req, res, next) ->
  res.send '',
    Location:'/'
  , 301


# ### Start server
app.listen process.env.PORT || 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
