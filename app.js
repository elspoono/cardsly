(function() {
  /*
  GENERIC LIBRARY LOADING AND SETUP
  *****************************************
  
  Express / Sendgrid / Coffeescript /  Imagemagick / etc etc etc
  
  *****************************************
  */
  var Card, CardSchema, Db, Image, ImageSchema, Message, MessageSchema, ObjectId, PDFDocument, Position, PositionSchema, Promise, Schema, Server, Template, TemplateSchema, Theme, ThemeSchema, User, UserSchema, View, ViewSchema, app, auth, bcrypt, compareEncrypted, conf, db, dbAuth, db_uri, encrypted, err, everyauth, express, geo, handleGoodResponse, im, mongoStore, mongodb, mongoose, nodemailer, parsed, rest, sessionStore, url, util;
  express = require("express");
  app = module.exports = express.createServer();
  conf = require('./lib/conf');
  im = require('imagemagick');
  geo = require('geo');
  require('coffee-script');
  PDFDocument = require('pdfkit');
  nodemailer = require('nodemailer');
  nodemailer.SMTP = {
    host: 'smtp.sendgrid.net',
    port: 25,
    use_authentication: true,
    user: process.env.SENDGRID_USERNAME,
    pass: process.env.SENDGRID_PASSWORD,
    domain: process.env.SENDGRID_DOMAIN
  };
  db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/staging';
  url = require('url');
  parsed = url.parse(db_uri);
  mongodb = require('mongodb');
  dbAuth = {};
  if (parsed.auth) {
    auth = parsed.auth.split(':', 2);
    dbAuth.username = auth[0];
    dbAuth.password = auth[1];
  }
  Db = mongodb.Db;
  Server = mongodb.Server;
  db = new Db(parsed.pathname.replace(/^\//, ''), new Server(parsed.hostname, parsed.port));
  mongoStore = require('connect-mongodb');
  mongoose = require('mongoose');
  mongoose.connect(db_uri);
  Schema = mongoose.Schema;
  ObjectId = Schema.ObjectId;
  sessionStore = new mongoStore({
    db: db,
    username: dbAuth.username,
    password: dbAuth.password
  });
  /*
  UTIL
  
  it's a useful for inspecting.
  
  USAGE:
  
  console.log util.inspect myVariableIWantToInspect
  
  */
  util = require('util');
  bcrypt = require('bcrypt');
  encrypted = function(inString) {
    var salt;
    salt = bcrypt.gen_salt_sync(10);
    return bcrypt.encrypt_sync(inString, salt);
  };
  compareEncrypted = function(inString, hash) {
    return bcrypt.compare_sync(inString, hash);
  };
  everyauth = require('everyauth');
  Promise = everyauth.Promise;
  /*
  DATABASE MODELING
  *****************************************
  
  All our schemas
  
  *****************************************
  */
  UserSchema = new Schema({
    email: String,
    password_encrypted: String,
    role: String,
    name: String,
    title: String,
    phone: String,
    company: String,
    fax: String,
    address: String,
    address_2: String,
    twitter_url: String,
    facebook_url: String,
    linkedin_url: String,
    custom_1: String,
    custom_2: String,
    custom_3: String,
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });
  UserSchema.static('authenticate', function(email, password, next) {
    return this.find({
      email: email,
      active: true
    }, function(err, data) {
      if (err) {
        return next('Database Error');
      } else {
        if (data.length > 0) {
          if (compareEncrypted(password, data[0].password_encrypted)) {
            return next(null, data[0]);
          } else {
            return next('Password incorrect.');
          }
        } else {
          return next('Email not found.');
        }
      }
    });
  });
  User = mongoose.model('User', UserSchema);
  CardSchema = new Schema({
    user_id: Number,
    print_id: Number,
    path: String,
    template_id: Number,
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });
  Card = mongoose.model('Card', CardSchema);
  ImageSchema = new Schema({
    height: Number,
    width: Number,
    buffer: String,
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });
  Image = mongoose.model('Image', ImageSchema);
  MessageSchema = new Schema({
    include_contact: Boolean,
    content: String,
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });
  Message = mongoose.model('Message', MessageSchema);
  TemplateSchema = new Schema({
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });
  Template = mongoose.model('Template', TemplateSchema);
  ThemeSchema = new Schema({
    template_id: Number,
    thumb_image_id: Number,
    preview_image_id: Number,
    big_image_id: Number,
    qr_size: Number,
    qr_x: Number,
    qr_y: Number
  });
  Theme = mongoose.model('Theme', ThemeSchema);
  PositionSchema = new Schema({
    theme_id: Number,
    order_id: Number,
    font_size: Number,
    x: Number,
    y: Number
  });
  Position = mongoose.model('Position', PositionSchema);
  ViewSchema = new Schema({
    ip_address: String,
    user_agent: String,
    card_id: Number,
    date_added: {
      type: Date,
      "default": Date.now
    }
  });
  View = mongoose.model('View', ViewSchema);
  /*
  EVERYAUTH STUFF
  *****************************************
  
  Authenticating to 3rd Party Providers
  
  *****************************************
  */
  handleGoodResponse = function(session, accessToken, accessTokenSecret, userMeta) {
    var promise, userSearch;
    promise = new Promise();
    userSearch = {};
    if (userMeta.publicProfileUrl) {
      userSearch.name = userMeta.firstName + ' ' + userMeta.lastName;
      userSearch.linkedin_url = userMeta.publicProfileUrl;
    }
    if (userMeta.link) {
      userSearch.name = userMeta.name;
      userSearch.facebook_url = userMeta.link;
    }
    if (userMeta.screen_name) {
      userSearch.name = userMeta.name;
      userSearch.twitter_url = 'http://twitter.com/#!' + userMeta.screen_name;
    }
    if (userMeta.email) {
      userSearch.email = userMeta.email;
    }
    User.findOne(userSearch, function(err, existingUser) {
      var user;
      if (err) {
        console.log('err: ', err);
        return promise.fail(err);
      } else if (existingUser) {
        console.log('user exists: ', existingUser);
        return promise.fulfill(existingUser);
      } else {
        user = new User;
        user.name = userSearch.name;
        user.linkedin_url = userSearch.linkedin_url;
        user.facebook_url = userSearch.facebook_url;
        user.twitter_url = userSearch.twitter_url;
        user.email = userSearch.email;
        return user.save(function(err, createdUser) {
          if (err) {
            console.log('err: ', err);
            return promise.fail(err);
          } else {
            console.log('user created: ', createdUser);
            return promise.fulfill(createdUser);
          }
        });
      }
    });
    return promise;
  };
  /*
  
  Create the Everyauth Accessing the user function
  
  per the "Accessing the user" section of the everyauth README
  
  */
  everyauth.everymodule.findUserById(function(userId, callback) {
    return User.findById(userId, callback);
  });
  everyauth.twitter.consumerKey('I4s77xbnJvV0bHa7wO8zTA');
  everyauth.twitter.consumerSecret('7JjalH7ZVkExJumLIDwsc8BkgxGoaxtSlipPmChY0');
  everyauth.twitter.findOrCreateUser(handleGoodResponse);
  everyauth.twitter.redirectPath('/success');
  everyauth.facebook.appId('292309860797409');
  everyauth.facebook.appSecret('70bcb1477ede9a706e285f7faafa8e32');
  everyauth.facebook.findOrCreateUser(handleGoodResponse);
  everyauth.facebook.redirectPath('/success');
  everyauth.linkedin.consumerKey('fuj9rhx302d7');
  everyauth.linkedin.consumerSecret('pvWmN5CkrdT3GHF3');
  everyauth.linkedin.findOrCreateUser(handleGoodResponse);
  everyauth.linkedin.redirectPath('/success');
  everyauth.google.appId('90634622438.apps.googleusercontent.com');
  everyauth.google.appSecret('Bvpnj5wXiakpkOnwmXyy4vDj');
  everyauth.google.findOrCreateUser(handleGoodResponse);
  everyauth.google.scope('https://www.googleapis.com/auth/userinfo.email');
  everyauth.google.redirectPath('/success');
  rest = require('./node_modules/everyauth/node_modules/restler');
  everyauth.google.fetchOAuthUser(function(accessToken) {
    var promise;
    promise = this.Promise();
    rest.get('https://www.googleapis.com/userinfo/email', {
      query: {
        oauth_token: accessToken,
        alt: 'json'
      }
    }).on('success', function(data, res) {
      var oauthUser;
      oauthUser = {
        email: data.data.email
      };
      return promise.fulfill(oauthUser);
    }).on('error', function(data, res) {
      return promise.fail(data);
    });
    return promise;
  });
  /*
  everyauth.googlehybrid.consumerKey 'cards.ly'
  everyauth.googlehybrid.consumerSecret 'C_UrIqmFopTXRPLFfFRcwXa9'
  everyauth.googlehybrid.findOrCreateUser handleGoodResponse
  everyauth.googlehybrid.scope ['email']
  everyauth.googlehybrid.redirectPath '/success'
  */
  everyauth.debug = true;
  app.configure(function() {
    app.set("views", __dirname + conf.dir.views);
    app.set("view engine", "jade");
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser());
    app.use(express.session({
      secret: conf.sessionSecret,
      store: sessionStore
    }));
    app.use(express.static(__dirname + conf.dir.public));
    return app.use(everyauth.middleware());
  });
  app.configure("development", function() {
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });
  app.configure("production", function() {
    return app.use(express.errorHandler());
  });
  /*
  ROUTES
  
  All of our routes are defined here
  
  */
  err = function(res, err) {
    return res.send('', {
      Location: '/error'
    }, 302);
  };
  app.get('/', function(req, res) {
    return res.render('index');
  });
  app.get('/success', function(req, res) {
    console.log('Request User: ', req.user);
    return res.render('success', {
      user: req.user
    });
  });
  app.get('/cards', function(req, res) {
    return res.render('cards');
  });
  app.get('/about', function(req, res) {
    return res.render('about');
  });
  app.get('/error', function(req, res) {
    return res.render('error');
  });
  app.get('/robots.txt', function(req, res, next) {
    return res.send('User-agent: *\nDisallow: ', {
      'Content-Type': 'text/plain'
    });
  });
  app.get(/^(?!(\/favicon.ico|\/images|\/js|\/css)).*$/, function(req, res, next) {
    return res.send('', {
      Location: '/'
    }, 301);
  });
  app.listen(process.env.PORT || process.env.C9_PORT || 4000);
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
}).call(this);
