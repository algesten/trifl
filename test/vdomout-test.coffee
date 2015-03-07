{capture, div, p, img} = require 'tagg'
VDOMOut = require '../src/vdomout'

describe 'VDOMOut', ->

    eqlvt = (vt, n, c, p) ->
        eql vt.tagName, n
        eql vt.properties, p
        eql vt.children.length, c

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

    it 'treats data-* attributes as DataHook', ->
        data = {}
        data['data-test'] = 'foo42'
        vt = capture out, -> div data
        h = vt.properties['data-test']
        assert.ok h instanceof VDOMOut.DataHook

    it 'treats on* attributes as EventHook', ->
        vt = capture out, -> div onclick: ->
        h = vt.properties['onclick']
        assert.ok h instanceof VDOMOut.EventHook

    describe 'DataHook', ->

        h = null

        beforeEach ->
            h = new VDOMOut.DataHook('panda')

        describe 'hook', ->

            it 'does setAttribute and node.dataset[camel]', ->
                node = setAttribute: spy()
                h.hook node, 'data-white-black-bear'
                eql node.setAttribute.args[0], ['data-white-black-bear', 'panda']
                eql node.dataset, whiteBlackBear:'panda'

        describe 'unhook', ->

            it 'does removeAttribute and delete node.dataset[camel]', ->
                node =
                    removeAttribute: spy()
                    dataset:whiteBlackBear:'panda'
                h.unhook node, 'data-white-black-bear'
                eql node.removeAttribute.args[0], ['data-white-black-bear']
                eql node.dataset, {}

    describe 'EventHook', ->

        h = null
        handler = ->

        beforeEach ->
            h = new VDOMOut.EventHook(handler)

        describe 'hook', ->

            it 'does addEventListener with the event name', ->
                node = addEventListener: spy()
                h.hook node, 'onclick'
                eql node.addEventListener.args[0], ['click', handler]

        describe 'unhook', ->

            it 'does removeEventListener with the event name', ->
                node = removeEventListener: spy()
                h.unhook node, 'onclick'
                eql node.removeEventListener.args[0], ['click', handler]
