// Generated by CoffeeScript 1.9.0
(function() {
  var I, OrderedMap, builtin, concat, indexof, mixin, select, startswith,
    __slice = [].slice;

  I = function(a) {
    return a;
  };

  builtin = I.bind.bind(I.call);

  startswith = function(s, i) {
    return s.slice(0, i.length) === i;
  };

  indexof = builtin(String.prototype.indexOf);

  concat = function() {
    var as, _ref;
    as = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = []).concat.apply(_ref, as);
  };

  mixin = function() {
    var k, o, os, r, v, _i, _len;
    os = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    r = {};
    for (_i = 0, _len = os.length; _i < _len; _i++) {
      o = os[_i];
      for (k in o) {
        v = o[k];
        r[k] = v;
      }
    }
    return r;
  };

  select = function(node, sel) {
    var doc;
    if (!node.parentNode) {
      doc = node.ownerDocument;
    }
    try {
      if (doc) {
        doc.body.appendChild(node);
      }
      switch (sel[0]) {
        case '.':
          return node.getElementsByClassName(sel.substring(1));
        case '#':
          return node.getElementById(sel.substring(1));
        default:
          return node.getElementsByTagName(sel);
      }
    } finally {
      if (doc) {
        doc.body.removeChild(node);
      }
    }
  };

  OrderedMap = (function() {
    function OrderedMap() {
      this.order = [];
      this.map = {};
    }

    OrderedMap.prototype.set = function(k, v) {
      if (!this.map.hasOwnProperty(k)) {
        this.order.push(k);
      }
      return this.map[k] = v;
    };

    OrderedMap.prototype.get = function(k) {
      return this.map[k];
    };

    return OrderedMap;

  })();

  module.exports = {
    startswith: startswith,
    indexof: indexof,
    select: select,
    concat: concat,
    mixin: mixin,
    OrderedMap: OrderedMap
  };

}).call(this);