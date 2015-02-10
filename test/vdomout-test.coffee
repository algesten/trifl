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
        eqlvt vt, 'div', 0, {}

    it 'renders a simple div', ->
        vt = capture out, -> div()
        eqlvt vt, 'div', 0, {}

    it 'renders a simple div with class', ->
        vt = capture out, -> div class:'foo'
        eqlvt vt, 'div', 0, class:'foo'

    it 'complains if the node is a void element', ->
        assert.throws (-> capture out, -> img()), 'Bad void element root: img'

    it 'renders a simple two level tree', ->
        vt = capture out, -> div -> p()
        eqlvt vt, 'div', 1, {}
        eqlvt vt.children[0], 'p', 0, {}

    it 'renders a complex tree', ->
        vt = capture out, tree
        eqlvt vt, 'div', 3, class:'special'
        eqlvt vt.children[0], 'div', 1, class:'widget'
        eqlvt vt.children[0].children[0], 'p', 1, {}
        eql vt.children[0].children[0].children[0].text, 'with stuff'
        eqlvt vt.children[1], 'p', 1, {}
        eql vt.children[1].children[0].text, 'nice pandas'
        eqlvt vt.children[2], 'img', 0, src:'/panda.jpg'
