(function() {

  /*
  
  THE APPLICATION
  
  - pretty much everything server side is in here
  - for now (intentionally for now, not lazy for now)
  - we'll separate it into files later, depending on how it evolves
  */

  /*
  
  LIBRARY LOADING
  
  - load in the libraries we'll use
  - do basic config on all of them
  */

  var Promise, app, bcrypt, card_schema, check_no_err, check_no_err_ajax, compareEncrypted, conf, connect, db_uri, encrypted, everyauth, express, form, fs, geo, handleGoodResponse, http, im, knox, knoxClient, line_schema, message_schema, mongo_card, mongo_message, mongo_theme, mongo_user, mongo_view, mongoose, nodemailer, object_id, options, redis_store, rest, samurai, schema, securedAdminPage, securedPage, session_store, theme_schema, theme_template_schema, ua_match, user_schema, util, view_schema;

  process.on('uncaughtException', function(err) {
    return console.log('UNCAUGHT', err);
  });

  express = require('express');

  http = require('http');

  form = require('connect-form');

  knox = require('knox');

  util = require('util');

  fs = require('fs');

  app = module.exports = express.createServer();

  conf = require('./lib/conf');

  im = require('imagemagick');

  samurai = require('samurai');

  samurai.setup({
    merchant_key: '89b14db44561382d457b5160',
    merchant_password: '6a5a0bf8906a6b8b1e577d72',
    processor_token: '5c44e876a2d1125015a872c3'
  });

  geo = require('geo');

  require('coffee-script');

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

  mongoose = require('mongoose');

  mongoose.connect(db_uri);

  schema = mongoose.Schema;

  object_id = schema.ObjectId;

  /*
  UTIL
  #
  #
  it's a useful for inspecting.
  #
  USAGE:
  #
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
  Knox - AMAZON S3 Connector
  Add the api keys and such
  */

  knoxClient = knox.createClient({
    key: 'AKIAI2CJEBPY77CQ32AA',
    secret: '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',
    bucket: 'cardsly'
  });

  ua_match = function(ua) {
    var match, result, rmozilla, rmsie, ropera, rwebkit;
    ua = ua.toLowerCase();
    rwebkit = /(webkit)[ \/]([\w.]+)/;
    ropera = /(opera)(?:.*version)?[ \/]([\w.]+)/;
    rmsie = /(msie) ([\w.]+)/;
    rmozilla = /(mozilla)(?:.*? rv:([\w.]+))?/;
    match = rwebkit.exec(ua) || ropera.exec(ua) || rmsie.exec(ua) || ua.indexOf('compatible') < 0 && rmozilla.exec(ua) || [];
    return result = {
      browser: match[1] || '',
      version: match[2] || '0'
    };
  };

  /*
  
  DATABASE MODELING
  
  - set up the schemas
  - they's all prefixed with mongo_
  */

  user_schema = new schema({
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

  user_schema.static('authenticate', function(email, password, next) {
    if (!email || !password || email === '' || password === '') {
      return next('Please enter an email address and password');
    } else {
      return mongo_user.findOne({
        email: email,
        active: true
      }, function(err, founduser) {
        if (err) {
          return next('Database Error');
        } else {
          if (founduser) {
            if (!founduser.password_encrypted) {
              return next('That email address is currently registered with a social account.<p>Please try logging in with a social network such as facebook or twitter.');
            } else if (compareEncrypted(password, founduser.password_encrypted)) {
              return next(null, founduser);
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

  mongo_user = mongoose.model('users', user_schema);

  card_schema = new schema({
    user_id: String,
    print_id: Number,
    path: String,
    theme_id: Number,
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });

  mongo_card = mongoose.model('cards', card_schema);

  message_schema = new schema({
    include_contact: Boolean,
    content: String,
    s3_id: String,
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });

  mongo_message = mongoose.model('messages', message_schema);

  line_schema = new schema({
    order_id: Number,
    color: String,
    font_family: String,
    text_align: String,
    h: Number,
    w: Number,
    x: Number,
    y: Number
  });

  theme_template_schema = new schema({
    qr: {
      color1: String,
      color2: String,
      color2_alpha: Number,
      radius: Number,
      h: Number,
      w: Number,
      x: Number,
      y: Number
    },
    lines: [line_schema],
    color1: String,
    color2: String,
    s3_id: String
  });

  theme_schema = new schema({
    category: String,
    theme_templates: [theme_template_schema],
    date_updated: {
      type: Date,
      "default": Date.now
    },
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    }
  });

  mongo_theme = mongoose.model('themes', theme_schema);

  view_schema = new schema({
    ip_address: String,
    user_agent: String,
    card_id: String,
    date_added: {
      type: Date,
      "default": Date.now
    }
  });

  mongo_view = mongoose.model('views', view_schema);

  /*
  
  EVERYAUTH CONFIG
  
  - authenticating to 3rd Party Providers
  */

  handleGoodResponse = function(session, accessToken, accessTokenSecret, userMeta) {
    var promise, userSearch;
    promise = new Promise();
    console.log(userMeta);
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
    if (userMeta.email) userSearch.email = userMeta.email;
    mongo_user.findOne(userSearch, function(err, existinguser) {
      var user;
      if (err) {
        console.log('err: ', err);
        return promise.fail(err);
      } else if (existinguser) {
        console.log('user exists: ', existinguser);
        return promise.fulfill(existinguser);
      } else {
        user = new mongo_user;
        user.name = userSearch.name;
        user.linkedin_url = userSearch.linkedin_url;
        user.facebook_url = userSearch.facebook_url;
        user.twitter_url = userSearch.twitter_url;
        user.email = userSearch.email;
        return user.save(function(err, createduser) {
          if (err) {
            console.log('err: ', err);
            return promise.fail(err);
          } else {
            console.log('user created: ', createduser);
            return promise.fulfill(createduser);
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
    return mongo_user.findById(userId, callback);
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
      var oauthuser;
      oauthuser = {
        email: data.data.email
      };
      return promise.fulfill(oauthuser);
    }).on('error', function(data, res) {
      return promise.fail(data);
    });
    return promise;
  });

  /*
  
  EXPRESS APPLICATION CONFIG
  
  - set route defaults
  - configure middleware, etc
  */

  connect = require('connect');

  redis_store = require('connect-redis')(connect);

  options = {};

  if (process.env.REDISTOGO_URL) {
    options = {
      host: process.env.REDISTOGO_URL.replace(/.*@([^:]*).*/ig, '$1'),
      port: process.env.REDISTOGO_URL.replace(/.*@.*:([^\/]*).*/ig, '$1'),
      pass: process.env.REDISTOGO_URL.replace(/.*:.*:(.*)@.*/ig, '$1')
    };
  }

  session_store = new redis_store(options);

  app.configure(function() {
    app.set("views", __dirname + conf.dir.views);
    app.set("view engine", "jade");
    app.set('view options', {
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
      store: session_store,
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
  
  POST ROUTES
  
  - for AJAX stuff mostly
  - maybe other post actions
  */

  app.post('/upload-image', function(req, res) {
    var s3_fail;
    s3_fail = function(err) {
      console.log('ERR: ', err);
      return res.send('<script>parent.window.$.s3_result(false);</script>');
    };
    try {
      return req.form.complete(function(err, fields, files) {
        var ext, fileName, path, size, sizes, _fn, _i, _len;
        if (err) {
          return s3_fail(err);
        } else {
          path = files.image.path;
          fileName = path.replace(/.*tmp\//ig, '');
          ext = fileName.replace(/.*\./ig, '');
          sizes = ['158x90', '525x300'];
          _fn = function(size) {
            return im.convert([path, '-filter', 'Quadratic', '-resize', size, '/tmp/' + size + fileName], function(err, smallImg, stderr) {
              if (err) {
                return s3_fail(err);
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
                    knoxReq.on('response', function(awsRes) {
                      if (awsRes.statusCode !== 200) console.log('ERR', awsRes);
                      if (size === '525x300') {
                        if (awsRes.statusCode === 200) {
                          return res.send('<script>parent.window.$.s3_result(\'' + fileName + '\');</script>');
                        } else {
                          return s3_fail(awsRes);
                        }
                      }
                    });
                    knoxReq.end(buff);
                    return fs.unlink('/tmp/' + size + fileName, function(err) {
                      if (err) return console.log('ERR:', err);
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
          return fs.readFile(path, function(err, buff) {
            var knoxReq;
            knoxReq = knoxClient.put('/raw/' + fileName, {
              'Content-Length': buff.length,
              'Content-Type': 'image/' + ext
            });
            knoxReq.on('response', function(res) {
              if (res.statusCode !== 200) return console.log('ERR', res);
            });
            return knoxReq.end(buff);
          });
        }
      });
    } catch (err) {
      return s3_fail(err);
    }
  });

  check_no_err_ajax = function(err) {
    if (err) {
      console.log(err);
      res.send({
        err: err
      });
    }
    return !err;
  };

  app.post('/save-theme', function(req, res) {
    var new_theme, params;
    params = JSON.parse(req.rawBody);
    req.session.theme = params.theme;
    if (params.do_save) {
      if (params.theme._id) {
        return mongo_theme.findById(params.theme._id, function(err, found_theme) {
          if (check_no_err_ajax(err)) {
            found_theme.category;
            found_theme.date_updated = new Date();
            if (typeof params.theme.active === 'boolean') {
              found_theme.active = params.theme.active;
            }
            found_theme.category = params.theme.category;
            found_theme.theme_templates = params.theme.theme_templates;
            return found_theme.save(function(err, theme_saved) {
              if (check_no_err_ajax(err)) {
                return res.send({
                  success: true,
                  theme: theme_saved
                });
              }
            });
          }
        });
      } else {
        new_theme = new mongo_theme;
        if (typeof params.theme.active === 'boolean') {
          new_theme.active = params.theme.active;
        }
        new_theme.category = params.theme.category;
        new_theme.theme_templates = params.theme.theme_templates;
        return new_theme.save(function(err, theme_saved) {
          if (check_no_err_ajax(err)) {
            return res.send({
              success: true,
              theme: theme_saved
            });
          }
        });
      }
    }
  });

  app.post('/save-form', function(req, res) {
    /*
      TODO
      
      We're going to have to save these form inputs in a cookie that expires faster.
      Like on browser close.
      It will be bad if someone else on the same computer comes to the page 2 weeks later and the first persons data is still showing there.
      Someone might be bothered by the privacy implications, even though it's data they put on their business cards which is fairly public.
    */
    var params;
    params = JSON.parse(req.rawBody);
    req.session.saved_form = params;
    return res.send({
      success: true
    });
  });

  app.post('/find-address', function(req, res, next) {
    return geo.geocoder(geo.google, req.body.address + ' ' + req.body.city, false, function(full_address, latitude, longitude, details) {
      console.log(full_address, latitude, longitude, details);
      full_address = full_address.replace(/,/, '<br>');
      req.session.saved_address = {
        address: req.body.address,
        city: req.body.city,
        full_address: full_address,
        latitude: latitude,
        longitude: longitude,
        details: details
      };
      return res.send({
        full_address: full_address
      });
    });
  });

  app.post('/check-email', function(req, res, next) {
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
      return mongo_user.count({
        email: req.email,
        active: true
      }, handleReturn);
    } else {
      return mongo_user.count({
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
    return mongo_user.authenticate(req.body.email, req.body.password, function(err, user) {
      if (err || !user) {
        return res.send({
          err: err
        });
      } else {
        req.session.auth = {
          userId: user._id
        };
        res.send({
          success: true
        });
        return console.log(req.user);
      }
    });
  });

  app.post('/send-feedback', function(req, res, next) {
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

  app.post('/create-user', function(req, res, next) {
    return mongo_user.count({
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
    user = new mongo_user();
    user.email = req.body.email;
    user.password_encrypted = encrypted(req.body.password);
    return user.save(function(err, data) {
      req.session.auth = {
        userId: user._id
      };
      return res.send({
        success: 'True'
      });
    });
  });

  app.post('/change-password', function(req, res, next) {
    req.user.password_encrypted = encrypted(req.body.new_password);
    return req.user.save(function(err, data) {
      return res.send({
        success: 'True'
      });
    });
  });

  app.post('/get-themes', function(req, res, next) {
    return mongo_theme.find({
      active: true
    }, [], {
      sort: {
        date_updated: 0
      }
    }, function(err, themes) {
      if (check_no_err_ajax(err)) {
        return res.send({
          themes: themes
        });
      }
    });
  });

  /*
  
  GET ROUTES
  
  - normal pages
  - anything that's a regular page
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

  check_no_err = function(err) {
    if (err) {
      console.log(err);
      res.send('', {
        Location: '/error'
      }, 302);
    }
    return !err;
  };

  app.get('/', function(req, res) {
    return res.render('landing-prelaunch', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing'
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

  app.get('/admin', securedAdminPage, function(req, res, next) {
    return res.render('admin', {
      user: req.user,
      session: req.session,
      scripts: ['/js/libs/colorpicker/js/colorpicker.js', '/js/libs/excanvas.compiled.js', '/js/admin.js']
    });
  });

  app.get('/make-me-admin', securedPage, function(req, res) {
    req.user.role = 'admin';
    return req.user.save(function(err) {
      if (err) console.log(err);
      return res.send('', {
        Location: '/admin'
      }, 302);
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
    return res.render('how-it-works', {
      user: req.user,
      session: req.session,
      whateverComesAfterHowItWorks: req.params.whateverComesAfterHowItWorks
    });
  });

  app.get('/settings', securedPage, function(req, res) {
    return res.render('settings', {
      user: req.user,
      session: req.session,
      scripts: ['/js/settings.js']
    });
  });

  app.get('/thank-you', function(req, res) {
    var paymentMethod, payment_method_token, total;
    payment_method_token = req.query.payment_method_token;
    if (payment_method_token) {
      total = (req.session.saved_form.quantity + req.session.saved_form.shipping_method) * 1;
      console.log(total);
      console.log(payment_method_token);
      return paymentMethod = samurai.PaymentMethod.find(payment_method_token, function(err, payment_method) {
        var purchase;
        console.log(payment_method.lastFourDigits());
        return purchase = samurai.Processor.purchase(payment_method_token, total, {
          billing_reference: 'billing data',
          customer_reference: 'customer data',
          custom: 'custom data',
          descriptor: 'descriptor'
        }, function(err, purchase) {
          if (err) {
            return console.log(err);
          } else {
            console.log(purchase.isSuccess());
            return res.render('thank-you', {
              user: req.user,
              session: req.session
            });
          }
        });
      });
    } else {
      return console.log('whoops');
    }
  });

  app.get('/splash', function(req, res) {
    return res.render('splash', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing'
    });
  });

  app.get('/error', function(req, res) {
    return res.render('error', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing'
    });
  });

  app.get('/cute-animal', function(req, res) {
    return res.render('cute-animal', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing'
    });
  });

  app.get('/home', function(req, res) {
    var ua;
    ua = ua_match(req.header('USER-AGENT'));
    if (ua.browser === 'msie' && parseInt(ua.version, 10) < 9) {
      return res.render('ie_home', {
        user: req.user,
        session: req.session
      });
    } else {
      return res.render('index', {
        user: req.user,
        session: req.session,
        scripts: ['/js/home.js']
      });
    }
  });

  /*
  
  Generic Routes
  
  - error handlers
  - redirects
  - robots.txt
  - etc
  */

  app.get('/error', function(req, res) {
    return res.render('error');
  });

  app.get('/robots.txt', function(req, res, next) {
    return res.send('user-agent: *\nDisallow: ', {
      'Content-Type': 'text/plain'
    });
  });

  app.get('/js/libs/PIE', function(req, res, next) {
    return res.sendfile(__dirname + '/public/js/libs/PIE.htc', {
      'Content-Type': 'text/x-component'
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
