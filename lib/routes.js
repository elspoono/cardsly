(function() {
  var app, kckb;
  app = require('../app');
  kckb = require('./kckb');
  app.get("/", function(req, res) {
    return res.render("index");
  });
}).call(this);
