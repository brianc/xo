fs = require "fs"

filed = require "filed"
express = require "express"
app = express()

app.set "view engine", "jade"
app.set "views", "#{__dirname}/views"

app.static = (url, path) ->
  path = if fs.existsSync path then path else require.resolve path
  throw new Error("Cannot locate #{path}") unless fs.existsSync path
  app.get url, (req, res) ->
    filed(path).pipe res

coffee = require "coffee-script"
app.coffee = (url, path) ->
  app.get url, (req, res, next) ->
    fs.readFile path, 'utf8', (err, script) ->
      return next err if err?
      res.writeHead 200, "content-type": "text/javascript"
      res.end coffee.compile script


app.static "/mocha.js", "mocha/mocha.js"
app.static "/mocha.css", "mocha/mocha.css"
app.static "/expect.js", "expect.js/expect.js"
app.coffee "/xo.js", "#{__dirname}/../../src/index.coffee"
app.coffee "/test/xo.js", "#{__dirname}/../index.coffee"

app.get "/", (req, res) ->
  res.render "index.jade"

app.use app.router
app.use express.errorHandler()

http = require "http"
http.createServer(app).listen 3030
