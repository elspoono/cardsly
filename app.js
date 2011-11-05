(function() {
  /*
  GENERIC LIBRARY LOADING AND SETUP
  *****************************************
  
  Express / Sendgrid / Coffeescript /  Imagemagick / etc etc etc
  
  *****************************************
  */
  var Card, CardSchema, Db, Image, ImageSchema, Message, MessageSchema, ObjectId, PDFDocument, Position, PositionSchema, Promise, Schema, Server, Template, TemplateSchema, Theme, ThemeSchema, User, UserSchema, View, ViewSchema, app, auth, bcrypt, compareEncrypted, conf, db, dbAuth, db_uri, encrypted, err, everyauth, express, form, fs, geo, handleGoodResponse, http, im, knox, knoxClient, mongoStore, mongodb, mongoose, nodemailer, parsed, rest, securedAdminPage, securedPage, sessionStore, sys, url, util;
  express = require('express');
  http = require('http');
  form = require('connect-form');
  knox = require('knox');
  sys = require('sys');
  fs = require('fs');
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
    if (!email || !password || email === '' || password === '') {
      return next('Please enter an email address and password');
    } else {
      return User.findOne({
        email: email,
        active: true
      }, function(err, foundUser) {
        if (err) {
          return next('Database Error');
        } else {
          if (foundUser) {
            if (!foundUser.password_encrypted) {
              return next('That email address is currently registered with a social account.<p>Please try logging in with a social network such as facebook or twitter.');
            } else if (compareEncrypted(password, foundUser.password_encrypted)) {
              return next(null, foundUser);
            } else {
              return next('Password incorrect for that email address.');
            }
          } else {
            return next('No account found for that email address.');
          }
        }
      });
    }
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
    category: String,
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
    width: Number,
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
  /*
  
  Knox - AMAZON S3 Connector
  
  Add the api keys and such
  
  */
  knoxClient = knox.createClient({
    key: 'AKIAI2CJEBPY77CQ32AA',
    secret: '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',
    bucket: 'cardsly'
  });
  app.configure(function() {
    app.set("views", __dirname + conf.dir.views);
    app.set("view engine", "jade");
    app.set('view options', {
      script: false,
      scripts: [],
      user: false,
      session: false
    });
    app.use(form({
      keepExtensions: true
    }));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser());
    app.use(express.session({
      secret: 'how now brown cow bow wow',
      store: sessionStore,
      cookie: {
        maxAge: 86400000 * 14
      }
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
  /*
  
  POST PAGES
  
  actions, like saving stuff, and checking stuff, from ajax
  
  */
  app.post('/uploadImage', function(req, res) {
    return req.form.complete(function(err, fields, files) {
      var ext, fileName, path, size, sizes, _fn, _i, _len;
      if (err) {
        return res.send({
          err: err
        });
      } else {
        path = files.image.path;
        fileName = path.replace(/.*tmp\//ig, '');
        ext = fileName.replace(/.*\./ig, '');
        sizes = ['158x90', '525x300'];
        _fn = function(size) {
          return im.convert([path, '-filter', 'Quadratic', '-resize', size, '/tmp/' + size + fileName], function(err, smallImg, stderr) {
            if (err) {
              return console.log('ERR:', err);
            } else {
              return fs.readFile('/tmp/' + size + fileName, function(err, buff) {
                var knoxReq;
                if (err) {
                  return console.log('ERR:', err);
                } else {
                  knoxReq = knoxClient.put('/' + size + '/' + fileName, {
                    'Content-Length': buff.length,
                    'Content-Type': 'image/' + ext
                  });
                  knoxReq.on('response', function(res) {
                    if (res.statusCode !== 200) {
                      console.log('ERR', res);
                    }
                    return console.log(knoxReq.url);
                  });
                  knoxReq.end(buff);
                  return fs.unlink('/tmp/' + size + fileName, function(err) {
                    if (err) {
                      return console.log('ERR:', err);
                    }
                  });
                }
              });
            }
          });
        };
        for (_i = 0, _len = sizes.length; _i < _len; _i++) {
          size = sizes[_i];
          _fn(size);
        }
        fs.readFile(path, function(err, buff) {
          var knoxReq;
          knoxReq = knoxClient.put('/raw/' + fileName, {
            'Content-Length': buff.length,
            'Content-Type': 'image/' + ext
          });
          knoxReq.on('response', function(res) {
            if (res.statusCode !== 200) {
              console.log('ERR', res);
            }
            return console.log(knoxReq.url);
          });
          return knoxReq.end(buff);
        });
        return res.send({
          success: true
        });
      }
    });
  });
  app.post('/saveForm', function(req, res) {
    /*
      TODO
      
      We're going to have to save these form inputs in a cookie that expires faster.
      Like on browser close.
      It will be bad if someone else on the same computer comes to the page 2 weeks later and the first persons data is still showing there.
      Someone might be bothered by the privacy implications, even though it's data they put on their business cards which is fairly public.
      */    req.session.savedInputs = req.body.inputs.split('`~`');
    return res.send({
      success: true
    });
  });
  app.post('/checkEmail', function(req, res, next) {
    var handleReturn, params;
    params = req.body || {};
    req.email = params.email || '';
    req.email = req.email.toLowerCase();
    handleReturn = function(err, count) {
      req.err = err;
      req.count = count;
      return next();
    };
    if (params.id) {
      return User.count({
        email: req.email,
        active: true
      }, handleReturn);
    } else {
      return User.count({
        email: req.email,
        active: true
      }, handleReturn);
    }
  }, function(req, res, next) {
    return res.send({
      err: req.err,
      count: req.count,
      email: req.email
    });
  });
  app.post('/login', function(req, res, next) {
    return User.authenticate(req.body.email, req.body.password, function(err, user) {
      if (err || !user) {
        return res.send({
          err: err
        });
      } else {
        req.session.auth = {
          userId: user._id
        };
        return res.send({
          success: true
        });
      }
    });
  });
  app.post('/sendFeedback', function(req, res, next) {
    res.send({
      succesfulFeedback: 'This worked!'
    });
    return nodemailer.send_mail({
      sender: req.body.email,
      to: 'support@cards.ly',
      cc: 'help@cards.ly',
      subject: 'Feedback email from:' + req.body.email,
      html: '<p>This is some feedback</p><p>' + req.body.content + '</p>'
    }, function(err, data) {
      if (err) {
        return console.log('ERR Feedback Email did not send:', err, req.body.email, req.body.content);
      }
    });
  });
  app.post('/createUser', function(req, res, next) {
    return User.count({
      email: req.body.email,
      active: true
    }, function(err, already) {
      if (already > 0) {
        return res.send({
          err: 'It looks like that email address is already registered with an account. It might be a social network account.<p>Try signing with a social network, such as facebook, linkedin, google+ or twitter.'
        });
      } else {
        return next();
      }
    });
  }, function(req, res, next) {
    var user;
    user = new User();
    user.email = req.body.email;
    user.password_encrypted = encrypted(req.body.password);
    return user.save(function(err, data) {
      return res.send({
        success: 'True'
      });
    });
  });
  /*
    nodemailer.send_mail({
      sender: 'notices@kickbackcard.com',
      to: signup.email,
      subject:'KickbackCard: Beta request for '+signup.name+' received',
      html: ''
      +'<p>Hi,</p>'
      +'<p>Your beta request has been received.  We will contact you in the next 1-2 business days.  Thank you for your interest in Kickback Card and we look forward to your participation.</p>'
      +'<p>Below is your vendor information that was submitted.</p>'
      +'<h3>'+signup.name+'</h3>'
      +'<div>'
        +'<div><b>Name:</b> '+signup.name+'</div>'
        +'<div>'+signup.address+'</div>'
        +'<div>'+signup.contact+'</div>'
        +'<div>'+signup.site_url+'</div>'
        +'<div>'+signup.yelp_url+'</div>'
        +'<div>'+signup.hours+'</div>'
        +'<div><b>Deal:</b> Buy '+signup.buy_qty+' '+signup.buy_item+' get '+signup.get_item+'</div>'
        +'<div><b>Email Registered:</b> '+signup.email+'</div>'
      +'</div>',
      body:'New Beta Request: '+signup.email
    },function(err, data){
  
    });
  */
  securedAdminPage = function(req, res, next) {
    if (req.user && req.user.role === 'admin') {
      return next();
    } else {
      return res.send('', {
        Location: '/cards'
      }, 302);
    }
  };
  securedPage = function(req, res, next) {
    if (req.user) {
      return next();
    } else {
      return res.send('', {
        Location: '/'
      }, 302);
    }
  };
  /*
  
  GET PAGES
  
  like the home page and about page and stuff
  
  */
  app.get('/', function(req, res) {
    return res.render('index', {
      user: req.user,
      session: req.session
    });
  });
  app.get('/success', function(req, res) {
    return res.render('success', {
      user: req.user,
      session: req.session
    });
  });
  app.get('/cards', securedPage, function(req, res) {
    return res.render('cards', {
      user: req.user,
      session: req.session
    });
  });
  app.get('/admin', securedAdminPage, function(req, res) {
    return res.render('admin', {
      user: req.user,
      session: req.session
    });
  });
  app.get('/login', function(req, res) {
    return res.render('login', {
      user: req.user,
      session: req.session
    });
  });
  app.get('/about', function(req, res) {
    return res.render('about', {
      user: req.user,
      session: req.session
    });
  });
  app.get('/how-it-works/:whateverComesAfterHowItWorks?', function(req, res) {
    console.log(req);
    return res.render('how-it-works', {
      user: req.user,
      session: req.session,
      whateverComesAfterHowItWorks: req.params.whateverComesAfterHowItWorks
    });
  });
  app.get('/error', function(req, res) {
    return res.render('error');
  });
  app.get('/robots.txt', function(req, res, next) {
    return res.send('User-agent: *\nDisallow: ', {
      'Content-Type': 'text/plain'
    });
  });
  app.get('*', function(req, res, next) {
    return res.send('', {
      Location: '/'
    }, 301);
  });
  app.listen(process.env.PORT || process.env.C9_PORT || 4000);
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
}).call(this);
