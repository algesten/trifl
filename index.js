/*global require, module, define*/

var mixin  = require('./lib/fun').mixin;
var route  = require('./lib/route');
var view   = require('./lib/view');
var action = require('./lib/action');

var exports = mixin(route, view, action);

if (typeof module === 'object') {
    module.exports = exports;
} else if (typeof define === 'function' && define.amd) {
    define(function() {
        return exports;
    });
} else {
    this.trifl = exports;
}
