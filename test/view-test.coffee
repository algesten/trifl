srlz = require('jsdom').serializeDocument
{div, p} = require 'tagg'

eql = assert.deepEqual

{view, layout} = require '../src/view'


describe 'view', ->

    it 'declares a view function with v.el undefined', ->
        v = view -> div class:'foo'
        # not rendered, so no class
        eql srlz(v.el), '<div></div>'
        v()
        eql srlz(v.el), '<div class="foo"></div>'

    it 'can change the outer tag', ->
        v = view -> p()
        v()
        eql srlz(v.el), '<p></p>'


describe 'layout', ->

    it 'declares a layout with regions specified as classes', ->
        l = layout top:'.top', bot:'.bot', ->
            div ->
                div class:'top'
                div class:'bot'
        eql typeof l.top, 'function'
        eql typeof l.bot, 'function'
        eql srlz(l.el), '<div><div class="top"></div><div class="bot"></div></div>'

    it 'takes views in regions', ->
        l = layout top:'.top', ->
            div class:'outer', ->
                div class:'top'
                div class:'bot'
        v = view -> div class:'view'
        v()
        l.top v
        eql srlz(l.el), '<div class="outer"><div class="top"><div class="view">\
            </div></div><div class="bot"></div></div>'
        assert.equal v._rg, l.top # same function

    describe 'operations', ->

        l = v = null
        beforeEach ->
            l = layout top:'.top', bot:'.bot', -> div class:'outer', ->
                div class:'top'
                div class:'bot'
            v = view -> div class:'view'
            v()

        it 'moves subviews from old to new region', ->
            l.top v
            eql srlz(l.el), '<div class="outer"><div class="top"><div class="view">\
                </div></div><div class="bot"></div></div>'
            eql srlz(l.el), '<div class="outer"><div class="top"><div class="view">\
                </div></div><div class="bot"></div></div>'


        it 'move view from region to region', ->
            l.top v
            eql srlz(l.el), '<div class="outer"><div class="top"><div class="view">\
                </div></div><div class="bot"></div></div>'
            l.bot v
            eql srlz(l.el), '<div class="outer"><div class="top"></div>\
                <div class="bot"><div class="view"></div></div></div>'
