#!/usr/bin/env node
// No coffee needed as this sources ./lib, not ./src:
// var coffee  = require("coffee-script/register");
var Baseamp = require("../");

var required = [ "username", "password", "account_id", "project_id" ];
var config   = {};
for (var i in required) {
  var cfgKey = required[i];
  var envKey = "BASECAMP_" + cfgKey.toUpperCase();

  if (!(envKey in process.env)) {
    console.error("Please first set the following environment key: " + envKey);
    if (cfgKey == "project_id") {
      console.error("Warning, first use a new/empty project before trying this on the real thing!");
    }
    process.exit(1);
  }
  config[cfgKey] = process.env[envKey];
}

var baseamp = new Baseamp(config);
var action  = process.argv[2];
var file    = process.argv[3];

if (!(action in baseamp)) {
  action = "help";
}

baseamp[action](file, function(err, stdout, stderr) {
  if (err) {
    throw err;
  }

  if (stderr) {
    console.error(stderr);
  }
  if (stdout) {
    console.log(stdout);
  }
});
