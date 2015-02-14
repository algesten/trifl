/*global require, exports*/
var mixin  = require('./lib/fun').mixin;
var route  = require('./lib/route');
var view   = require('./lib/view');
var action = require('./lib/action');
var tagg   = {tagg:require('tagg')};

module.exports = mixin(route, view, action, tagg);
