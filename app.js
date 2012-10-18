require('coffee-script');
require('js-yaml');
/**
 * Module dependencies.
 */

var express = require('express')
  , stylus = require('stylus')
  , http = require('http')
  , path = require('path')
  , flash = require('connect-flash')
  , sessionStore = new express.session.MemoryStore
  , MongoStore = require('connect-mongo')(express);

require('express-namespace');


// Database Setup
var mongoose = require('mongoose');
var config = require('./config/mongo.yml');
var db = require('./models/database')(mongoose, config);

var app = module.exports = express();

find_db_name = function() {
  switch (process.env.NODE_ENV) {
  case "development":
    return config.development.database;
    break;
  case "test":
    return config.test.database;
    break;
  case "production":
    return config.production.database;
    break;
  default:
    throw new Error("Please make sure there is a database for the specified environment");
  }
};

var settings = {
  db: find_db_name(),
  secret: 'NRVe8NxGkgFUQdbTGcauymqW'
};

var store = new MongoStore({
      db: settings.db
    });


app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('NRVe8NxGkgFUQdbTGcauymqW'));
  app.use(express.session({
    key: 'express.sid',
    secret: settings.secret,
    store:  sessionStore
  }));
  app.use(flash());
  app.use(require('connect-assets')());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'assets')));
});

app.configure('test', function () {
  app.set('port', 3001);
});

app.configure('development', function(){
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

app.configure('production', function () {
  app.use(express.errorHandler());
});

// Global helpers
require('./apps/helpers')(app);

// Routes
require('./middleware/upgrade')(app);
require('./apps/authentication/routes')(app, mongoose, db);
require('./apps/interact/routes')(app, mongoose, db);

server = http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});

// Socket-Io
require('./apps/socket-io')(app, server, mongoose, db, sessionStore);
