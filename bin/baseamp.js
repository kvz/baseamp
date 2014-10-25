#!/usr/bin/env node
// No coffee needed as this sources ./lib, not ./src:
// var coffee  = require("coffee-script/register");
var Baseamp = require("../");

var baseamp = new Baseamp({
  username  : process.env.BASECAMP_USERNAME,
  password  : process.env.BASECAMP_PASSWORD,
  account_id: process.env.BASECAMP_ACCOUNT_ID,
  project_id: process.env.BASECAMP_PROJECT_ID
});

var action = process.argv[2];
var file   = process.argv[3];

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
