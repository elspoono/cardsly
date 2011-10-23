# Get app to set routes to app
app = require '../app'

# Get functions for function type tests
kckb = require './kckb'

app.get "/", (req, res) ->
  res.render "index"