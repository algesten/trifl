/*global require, module*/
var mixin  = require('./lib/fun').mixin;
var expose = require('./lib/fun').expose;
var route  = require('./lib/route');
var view   = require('./lib/view');
var action = require('./lib/action');
var tagg   = {tagg:require('tagg')};

var exports = mixin(route, view, action, tagg);

exports.expose   = expose(exports,   '__trifl');
tagg.tagg.expose = expose(tagg.tagg, '__tagg');

module.exports = exports;
