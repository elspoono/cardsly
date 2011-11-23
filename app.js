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

  var Promise, app, bcrypt, card_schema, check_no_err, check_no_err_ajax, compareEncrypted, conf, connect, consonants, db_uri, encrypted, everyauth, express, form, fs, geo, get_order_info, handleGoodResponse, http, i, im, knox, knoxClient, l, line_schema, message_schema, mongo_card, mongo_message, mongo_order, mongo_theme, mongo_url, mongo_user, mongo_view, mongoose, mrg, new_url, nodemailer, numbers, object_id, options, order_schema, pre_consonants, pre_vowels, redis_store, rest, samurai, schema, securedAdminPage, securedPage, session_store, status_schema, stripe, theme_schema, theme_template_schema, ua_match, url_schema, user_schema, util, valid_new_url, valid_url_characters, view_schema, vowels, _i, _j, _len, _len2, _ref, _ref2;

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
    customer: {
      id: String,
      active_card: {
        cvc_check: String,
        exp_month: Number,
        exp_year: Number,
        last4: String,
        type: String
      }
    },
    /*
      payment_method:
        token: String
        card_type: String
        last_four_digits: String
        expiry_month: String
        expiry_year: String
    */
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

  status_schema = new schema({
    status: String,
    user_id: String,
    date_added: {
      type: Date,
      "default": Date.now
    }
  });

  order_schema = new schema({
    order_number: String,
    user_id: String,
    theme_id: String,
    status: String,
    status_history: [status_schema],
    quantity: Number,
    shipping_method: Number,
    tracking_number: String,
    values: [String],
    address: String,
    city: String,
    full_address: String,
    amount: Number,
    email: String,
    shipping_email: String,
    confirm_email: String,
    charge: {
      id: String,
      paid: Boolean,
      refunded: Boolean,
      card: {
        cvc_check: String,
        exp_month: Number,
        exp_year: Number,
        last4: String,
        type: String
      }
    },
    date_added: {
      type: Date,
      "default": Date.now
    }
  });

  mongo_order = mongoose.model('orders', order_schema);

  url_schema = new schema({
    url_string: String,
    user_id: String,
    redirect_to: String
  });

  mongo_url = mongoose.model('urls', url_schema);

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
        console.log('ERR: ', err);
        return promise.fail(err);
      } else if (existinguser) {
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
            console.log('ERR: ', err);
            return promise.fail(err);
          } else {
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

  everyauth.google.appId('90634622438-pn8nk974spacthoc1joflnkqhk9hj60q.apps.googleusercontent.com');

  everyauth.google.appSecret('7TOwXY-cPbbpgb6u9Y_kSfnX');

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
  TODO
  
  For middleware
  - Make the session and user objects sent on every request sent automatically instead of being something we have to pass each time to the jade.
  */

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
      env: app.settings.env,
      user: false,
      session: false,
      error_message: false
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

  mrg = require(__dirname + '/mrg');

  valid_url_characters = [];

  pre_vowels = [['e', 12], ['a', 8], ['o', 7], ['i', 7], ['u', 3], ['y', 2]];

  pre_consonants = [['t', 9], ['n', 7], ['s', 6], ['h', 6], ['r', 5], ['d', 4], ['l', 4], ['c', 3], ['m', 2], ['w', 2], ['f', 2], ['g', 2], ['y', 2], ['p', 2], ['b', 2], ['k', 1], ['j', 1], ['x', 1], ['qu', 1], ['z', 1]];

  vowels = [];

  for (_i = 0, _len = pre_vowels.length; _i < _len; _i++) {
    l = pre_vowels[_i];
    for (i = 1, _ref = l[1]; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
      vowels.push(l[0]);
    }
  }

  consonants = [];

  for (_j = 0, _len2 = pre_consonants.length; _j < _len2; _j++) {
    l = pre_consonants[_j];
    for (i = 1, _ref2 = l[1]; 1 <= _ref2 ? i <= _ref2 : i >= _ref2; 1 <= _ref2 ? i++ : i--) {
      consonants.push(l[0]);
    }
  }

  numbers = ['', 1, 2, 3, 4, 5, 6, 7, 8, 9];

  new_url = function() {
    var add_consonant, add_consonant_upper, add_number, add_vowel, c_l, n_l, psuedo, v_l;
    psuedo = '';
    c_l = consonants.length - 1;
    v_l = vowels.length - 1;
    n_l = numbers.length - 1;
    add_number = function() {
      var i;
      for (i = 0; i <= 1; i++) {
        psuedo += numbers[Math.round(mrg.generate_real() * n_l)];
      }
      if (Math.round(mrg.generate_real())) return psuedo += 0;
    };
    add_consonant_upper = function() {
      var consonant, i, _results;
      _results = [];
      for (i = 0; i <= 0; i++) {
        consonant = consonants[Math.round(mrg.generate_real() * c_l)];
        if (Math.round(mrg.generate_real())) {
          _results.push(psuedo += consonant);
        } else {
          _results.push(psuedo += consonant.toUpperCase());
        }
      }
      return _results;
    };
    add_vowel = function() {
      var i, vowel, _results;
      _results = [];
      for (i = 0; i <= 0; i++) {
        vowel = vowels[Math.round(mrg.generate_real() * v_l)];
        psuedo += vowel;
        if (Math.round(mrg.generate_real())) {
          _results.push(psuedo += vowel);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    add_consonant = function() {
      var i, _results;
      _results = [];
      for (i = 0; i <= 0; i++) {
        _results.push(psuedo += consonants[Math.round(mrg.generate_real() * c_l)]);
      }
      return _results;
    };
    add_consonant_upper();
    add_vowel();
    add_consonant();
    add_vowel();
    add_consonant();
    add_number();
    return psuedo;
  };

  valid_new_url = function(next) {
    var try_url;
    try_url = new_url();
    return mongo_url.count({
      url_string: try_url
    }, function(err, count) {
      if (err) next(err);
      if (!count) {
        return next(null, try_url);
      } else {
        return valid_new_url(next);
      }
    });
  };

  /*
  for i in [0..100]
    valid_new_url (err, url) ->
      if err
        console.log 'ERR: ', err
      else
        console.log url
  */

  app.post('/upload-image', function(req, res) {
    var s3_fail;
    s3_fail = function(err) {
      console.log('ERR: ', err);
      return res.send('<script>parent.window.$.s3_result(false);</script>');
    };
    try {
      return req.form.complete(function(err, fields, files) {
        var ext, fileName, path, size, sizes, _fn, _k, _len3;
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
          for (_k = 0, _len3 = sizes.length; _k < _len3; _k++) {
            size = sizes[_k];
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
      console.log('ERR: ', err);
      res.send({
        err: err
      });
    }
    return !err;
  };

  app.post('/save-theme', function(req, res) {
    var new_theme, params;
    params = req.body;
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
    */    req.session.saved_form = req.body;
    return res.send({
      success: true
    });
  });

  app.post('/find-address', function(req, res, next) {
    return geo.geocoder(geo.google, req.body.address + ' ' + req.body.city, false, function(full_address, latitude, longitude, details) {
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
      sender: req.body.email || 'help@cards.ly',
      to: 'support@cards.ly',
      cc: 'help@cards.ly',
      subject: 'Feedback email from:' + req.body.email,
      html: '<p>This is some feedback</p><p>' + req.body.content + '</p>'
    }, function(err, data) {
      if (err) {
        return console.log('ERR: Feedback Email did not send - ', err, req.body.email, req.body.content);
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
    if (encrypted(req.body.current_password) === req.user.password_encrypted) {
      req.user.password_encrypted = encrypted(req.body.new_password);
      return req.user.save(function(err, data, wp) {
        return res.send({
          success: 'True'
        });
      });
    } else {
      return req.user(function(err, data, wp) {
        return res.send({
          password_wrong: 'True'
        });
      });
    }
  });

  app.post('/get-user', function(req, res, next) {
    return res.send({
      name: req.user.name,
      email: req.user.email,
      active_card: req.user.customer.active_card
      /*
          payment_method:
            card_type: req.user.payment_method.card_type
            last_four_digits: req.user.payment_method.last_four_digits
            expiry_month: req.user.payment_method.expiry_month
            expiry_year: req.user.payment_method.expiry_year
      */
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

  stripe = require('./stripe_installed.js')('SXiUQj37CG6bszZQrkxKZVmQI7bZgLpW');

  if (app.settings.env === 'development') {
    stripe = require('./stripe_installed.js')('VGZ3wGSA2ygExWhd6J9pjkhSD5uqlE7u');
  }

  app.post('/confirm-purchase', function(req, res, next) {
    return valid_new_url(function(err, url) {
      var order;
      if (err) {
        console.log('ERR: url generate resulted in ', err);
        return res.send({
          err: err
        });
      } else {
        order = new mongo_order;
        order.order_number = url;
        order.user_id = req.user._id;
        order.theme_id = req.session.saved_form.active_theme_id;
        order.status = 'Pending';
        order.quantity = req.session.saved_form.quantity;
        order.shipping_method = req.session.saved_form.shipping_method;
        order.values = req.session.saved_form.values;
        order.address = req.session.saved_address.address;
        order.city = req.session.saved_address.city;
        order.full_address = req.session.saved_address.full_address;
        order.amount = (req.session.saved_form.quantity * 1 + req.session.saved_form.shipping_method * 1) * 100;
        order.email = req.body.email;
        order.shipping_email = req.body.shipping_email;
        order.confirm_email = req.body.confirm_email;
        return order.save(function(err, new_order) {
          if (err) {
            console.log('ERR: database ', err);
            return res.send({
              err: err
            });
          } else {
            console.log('AMOUNT: ', new_order.amount);
            return stripe.customers.create({
              card: req.body.token,
              email: req.user.email || null,
              description: req.user.name || req.user.email || req.user.id
            }, function(err, customer) {
              if (err) {
                console.log('ERR: stripe customer create resulted in ', err, customer);
                return res.send({
                  err: customer.error.message
                });
              } else {
                console.log('CUSTOMER: ', customer);
                req.user.customer = customer;
                req.user.save(function(err, user_saved) {
                  if (err) return console.log('ERR: database ', err);
                });
                console.log('');
                return stripe.charges.create({
                  currency: 'usd',
                  amount: new_order.amount * 1,
                  customer: customer.id,
                  description: req.user.name + ', ' + req.user.email + ', ' + new_order._id
                }, function(err, charge) {
                  console.log('CHARGE: ', charge);
                  new_order.status = 'Failed';
                  if (err) {
                    console.log('ERR: stripe charge resulted in ', err);
                    res.send({
                      err: charge.error.message
                    });
                  } else if (!charge.paid) {
                    console.log('ERR: stripe charge resulted in not paid for some reason.');
                    res.send({
                      err: 'Charge resulted in not paid for some reason.'
                    });
                  } else {
                    new_order.status = 'Charged';
                    res.send({
                      order_id: new_order._id,
                      charge: charge
                    });
                    if (new_order.confirm_email && new_order.email) {
                      nodemailer.send_mail({
                        sender: 'help@cards.ly',
                        to: 'support@cards.ly',
                        cc: 'help@cards.ly',
                        subject: 'Cardsly Order Confirmation - ' + new_order.order_number,
                        html: '<p>' + (req.user.name || req.user.email) + ',</p><p>We\'ve received your order and are processing it now.</p><p>Please don\'t hesitate to let us know if you have any questions at any time. <p>Reply to this email, call us at 480.828.8000, or reach <a href="http://twitter.com/cardsly">us</a> on <a href="http://facebook.com/cardsly">any</a> <a href="https://plus.google.com/101327189030192478503/posts">social network</a>. </p>'
                      }, function(err, data) {
                        if (err) {
                          return console.log('ERR: Confirm email did not send - ', err, new_order.order_number);
                        }
                      });
                    }
                  }
                  new_order.charge = charge;
                  return new_order.save(function(err, final_order) {
                    if (err) return console.log('ERR: database ', err);
                  });
                });
              }
            });
          }
        });
      }
    });
  });

  app.post('/validate-purchase', function(req, res, next) {
    if (!req.user) {
      return res.send({
        error: 'Please sign in'
      });
    } else if (!req.session.saved_address) {
      return res.send({
        error: 'Please enter shipping info'
      });
    } else if (!req.session.saved_address.full_address) {
      return res.send({
        error: 'Please check the address'
      });
    } else if (req.session.saved_form.values[0] === "John Stamos") {
      return res.send({
        error: 'Hey Uncle Jesse, is that you?'
      });
    } else {
      /*
          TODO
          
          - SAVE THEIR INFO HERE
      */
      return res.send({
        success: true
      });
      /*
          res.send
            error: 'Im sorry this page isnt active yet'
      */
    }
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

  if (app.settings.env === 'production') {
    app.get('*', function(req, res, next) {
      var headers;
      headers = req.headers;
      if (headers['x-real-ip'] && headers['x-forwarded-proto'] !== 'https') {
        return res.send('', {
          Location: 'https://www.cards.ly' + req.url
        }, 302);
      } else {
        return next();
      }
    });
  }

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

  get_order_info = function(req, res, next) {
    return mongo_order.find({
      user_id: req.user._id,
      'charge.paid': true
    }, function(err, orders) {
      if (check_no_err(err)) {
        req.orders = orders;
        return next();
      }
    });
  };

  app.get('/cards', get_order_info, securedPage, function(req, res) {
    return res.render('cards', {
      orders: req.orders,
      user: req.user,
      session: req.session,
      thankyou: false
    });
  });

  app.get('/cards/thank-you', get_order_info, securedPage, function(req, res) {
    return res.render('cards', {
      orders: req.orders,
      user: req.user,
      session: req.session,
      thankyou: true
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

  /*
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
  */

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
    var ua, ua_string;
    ua_string = req.header('USER-AGENT');
    ua = ua_match(ua_string);
    if (ua.browser === 'msie' && parseInt(ua.version, 10) < 9) {
      return res.render('simple_home', {
        user: req.user,
        session: req.session
      });
    } else if (ua_string.match(/mobile/i)) {
      return res.render('simple_home', {
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

  app.get('/beepBoop10', function(req, res) {
    var url, urls;
    urls = ['http://facebook.com/elforko', 'http://twitter.com/elspoono', 'http://blog.cards.ly', 'http://elspoono.wordpress.com', 'http://www.meetup.com/webdesignersdevelopers/members/8256239/', 'http://www.slideshare.net/elspoono', 'https://plus.google.com/100278450741153543517/posts', 'http://github.com/elspoono'];
    url = urls[Math.round(mrg.generate_real() * (urls.length - 1))];
    return res.send('', {
      Location: url
    }, 302);
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
