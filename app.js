// the port
var port = 8000;

var express = require('express');
var app = express();

// serve the 'build' folder as static assets
app.use(express.static(__dirname + '/build'));

// start the server
app.listen(port, function() {
  console.log('Server listening on port: ' + port);
});
