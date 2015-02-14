jsdom           = require('jsdom').jsdom
global.window   = jsdom().defaultView
global.document = window.document
global.srlz     = require('jsdom').serializeDocument

global.document.__JSDOM = 'jsdom'

chai   = require 'chai'
global.assert = chai.assert
global.eql = assert.deepEqual
chai.use require 'sinon-chai'
sinon  = require 'sinon'
global.stub = sinon.stub
global.spy  = sinon.spy
global.sandbox = sinon.sandbox
