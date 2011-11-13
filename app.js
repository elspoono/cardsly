(function() {

  /*
  GENERIC LIBRARY LOADING AND SETUP
  *****************************************
  
  Express / Sendgrid / Coffeescript /  Imagemagick / etc etc etc
  
  *****************************************
  */

  var Db, PDFDocument, Promise, Server, app, auth, bcrypt, card_schema, check_no_err, check_no_err_ajax, compareEncrypted, conf, db, dbAuth, db_uri, encrypted, err, everyauth, express, form, fs, geo, handleGoodResponse, http, im, knox, knoxClient, message_schema, mongoStore, mongo_card, mongo_message, mongo_position, mongo_theme, mongo_theme_group, mongo_user, mongo_view, mongodb, mongoose, nodemailer, object_id, parsed, position_schema, rest, schema, securedAdminPage, securedPage, session_store, theme_group_schema, theme_schema, url, user_schema, util, view_schema;

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

  schema = mongoose.Schema;

  object_id = schema.ObjectId;

  session_store = new mongoStore({
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

  theme_group_schema = new schema({
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

  mongo_theme_group = mongoose.model('theme_groups', theme_group_schema);

  theme_schema = new schema({
    date_added: {
      type: Date,
      "default": Date.now
    },
    active: {
      type: Boolean,
      "default": true
    },
    theme_group_id: String,
    qr_color1: String,
    qr_color2: String,
    qr_color2_alpha: Number,
    qr_radius: Number,
    qr_h: Number,
    qr_w: Number,
    qr_x: Number,
    qr_y: Number,
    color1: String,
    color2: String,
    s3_id: String
  });

  mongo_theme = mongoose.model('themes', theme_schema);

  position_schema = new schema({
    theme_id: String,
    order_id: Number,
    color: String,
    font_family: String,
    text_align: String,
    h: Number,
    w: Number,
    x: Number,
    y: Number
  });

  mongo_position = mongoose.model('positions', position_schema);

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
              if (res.statusCode !== 200) console.log('ERR', res);
              return console.log(knoxReq.url);
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
    var params, theme_group;
    params = JSON.parse(req.rawBody);
    console.log(util.inspect(params));
    console.log(util.inspect(params.theme.positions));
    req.session.theme = params.theme;
    if (params.do_save) {
      if (params.theme._id) {
        return console.log(params.theme);
      } else {
        theme_group = new mongo_theme_group;
        theme_group.category = params.theme.category;
        return theme_group.save(function(err, new_theme_group) {
          var theme;
          if (check_no_err_ajax(err)) {
            theme = new mongo_theme;
            theme.theme_group_id = new_theme_group._id;
            theme.qr_x = params.theme.qr_x;
            theme.qr_y = params.theme.qr_y;
            theme.qr_h = params.theme.qr_h;
            theme.qr_w = params.theme.qr_w;
            theme.qr_color1 = params.theme.qr_color1;
            theme.qr_color2 = params.theme.qr_color2;
            theme.qr_radius = params.theme.qr_radius;
            theme.qr_color2_alpha = params.theme.qr_color2_alpha;
            theme.color1 = params.theme.color1;
            theme.color2 = params.theme.color2;
            theme.s3_id = params.theme.s3_id;
            return theme.save(function(err, new_theme) {
              var i, param_position, position, _len, _ref, _results;
              if (check_no_err_ajax(err)) {
                res.send({
                  success: true,
                  theme: new_theme
                });
                _ref = params.theme.positions;
                _results = [];
                for (param_position = 0, _len = _ref.length; param_position < _len; param_position++) {
                  i = _ref[param_position];
                  position = new mongo_position;
                  position.theme_id = new_theme._id;
                  position.order_id = i;
                  position.x = param_position.x;
                  position.y = param_position.y;
                  position.h = param_position.h;
                  position.w = param_position.w;
                  position.text_align = param_position.text_align;
                  position.color = param_position.color;
                  position.font_family = param_position.font_family;
                  _results.push(position.save(function(err, new_theme_position) {
                    if (err) return console.log('POSITION SAVE ERR: ', err);
                  }));
                }
                return _results;
              }
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
    */    req.session.savedInputs = req.body.inputs.split('`~`');
    return res.send({
      success: true
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
        return res.send({
          success: true
        });
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
      return res.send({
        success: 'True'
      });
    });
  });

  app.post('/change-password', function(req, res, next) {
    user.password_encrypted = encrypted(req.body.password);
    return user.save(function(err, data) {
      return res.send({
        success: 'True'
      });
    });
  });

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

  /*
  
  GET PAGES
  
  like the home page and about page and stuff
  */

  app.get('/', function(req, res) {
    return res.render('landing-prelaunch', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing_page'
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
    return mongo_theme_group.find({
      active: true
    }, function(err, theme_groups) {
      if (check_no_err(err)) {
        console.log(theme_groups);
        /*
        
              DEREK
        
        
        
              YOU WERE HERE
        
        
              - find the themes for that theme group
              - next
              - find the positions
              - next
              - render with that data
              - loop through that in the admin
        */
        return res.render('admin', {
          user: req.user,
          session: req.session,
          scripts: ['/js/libs/colorpicker/js/colorpicker.js', '/js/libs/qrcode.js', '/js/libs/excanvas.compiled.js', '/js/admin.js']
        });
      }
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

  app.get('/thank_you', function(req, res) {
    return res.render('thank_you', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing_page'
    });
  });

  app.get('/splash', function(req, res) {
    return res.render('splash', {
      user: req.user,
      session: req.session,
      layout: 'layout_landing_page'
    });
  });

  app.get('/home', function(req, res) {
    return res.render('index', {
      user: req.user,
      session: req.session
    });
  });

  app.get('/error', function(req, res) {
    return res.render('error');
  });

  app.get('/robots.txt', function(req, res, next) {
    return res.send('user-agent: *\nDisallow: ', {
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
