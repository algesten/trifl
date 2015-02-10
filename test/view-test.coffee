{div, p} = require 'tagg'

eql = assert.deepEqual

{view, layout} = require '../src/view'

describe 'view', ->

    it 'declares a view function with v.el undefined', ->
        v = view -> div()
        eql v.el.tagName, 'DIV'

    it 'can change the outer', ->
        v = view -> p()
        v()
        eql v.el.tagName, 'P'
