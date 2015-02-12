{capture, div, p, img} = require 'tagg'
VDOMOut = require '../src/vdomout'

eql = assert.deepEqual

eqlvt = (vt, n, c, p) ->
        eql vt.tagName, n
        eql vt.properties, p
        eql vt.children.length, c

describe 'VDOMOut', ->

    tree = ->
        div class:'special', ->
            div class:'widget', ->
                p 'with stuff'
            p 'nice pandas'
            img src:'/panda.jpg'

    out = null

    beforeEach ->
        out = new VDOMOut()

    it 'renders the simplest div', ->
        vt = capture out, div

        eqlvt vt, 'div', 0, attributes:{}

    it 'renders a simple div', ->
        vt = capture out, -> div()
        eqlvt vt, 'div', 0, attributes:{}

    it 'renders a simple div with class', ->
        vt = capture out, -> div className:'foo'
        eqlvt vt, 'div', 0, className:'foo', attributes:{}

    it 'complains if the node is a void element', ->
        assert.throws (-> capture out, -> img()), 'Bad void element root: img'

    it 'renders a simple two level tree', ->
        vt = capture out, -> div -> p()
        eqlvt vt, 'div', 1, attributes:{}
        eqlvt vt.children[0], 'p', 0, attributes:{}

    it 'renders a complex tree', ->
        vt = capture out, tree
        eqlvt vt, 'div', 3, {className:'special', attributes:{}}
        eqlvt vt.children[0], 'div', 1, {className:'widget', attributes:{}}
        eqlvt vt.children[0].children[0], 'p', 1, attributes:{}
        eql vt.children[0].children[0].children[0].text, 'with stuff'
        eqlvt vt.children[1], 'p', 1, attributes:{}
        eql vt.children[1].children[0].text, 'nice pandas'
        eqlvt vt.children[2], 'img', 0, attributes:src:'/panda.jpg'
