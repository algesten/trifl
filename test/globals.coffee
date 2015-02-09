g = (global || window)

chai   = require 'chai'
g.assert = chai.assert
chai.use require 'sinon-chai'
sinon  = require 'sinon'
g.stub = sinon.stub
g.spy  = sinon.spy
