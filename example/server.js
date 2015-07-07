var express = require("express"), path = require("path");

express()
  .use(express.static(path.join(__dirname, "public")))
  .listen(8080, function() { console.log(" listening on port 8080"); });
