(function() {
  var Db, ObjectId, PDFDocument, Promise, Schema, Server, app, auth, bcrypt, compareEncrypted, conf, db, dbAuth, db_uri, encrypted, everyauth, express, geo, im, mongoStore, mongodb, mongoose, nodemailer, parsed, sessionStore, url;
  express = require("express");
  app = module.exports = express.createServer();
  conf = require('./lib/conf');
  /*
   Stuff we add to every app to setup sessions and mongo and mailing to work on heroku and locally
  */
  im = require('imagemagick');
  db_uri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost:27017/staging';
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
  everyauth.twitter.consumerKey('I4s77xbnJvV0bHa7wO8zTA');
  everyauth.twitter.consumerSecret('7JjalH7ZVkExJumLIDwsc8BkgxGoaxtSlipPmChY0');
  everyauth.twitter.findOrCreateUser(function(session, accessToken, accessTokenSecret, twitterUserMetadata) {
    var promise;
    promise = new Promise();
    console.log(twitterUserMetadata);
    everyAuth.fulfull(twitterUserMetadata);
    return promise;
  });
  everyauth.twitter.redirectPath('/');
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
  app.get('/', function(req, res) {
    return res.render('index', {
      script: 'home',
      title: 'KickbackCard - iPhone App Loyalty Card Program'
    });
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
  app.listen(process.env.PORT || 3000);
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
}).call(this);
