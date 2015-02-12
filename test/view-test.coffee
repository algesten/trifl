srlz = require('jsdom').serializeDocument
{div, p, input} = require 'tagg'

eql = assert.deepEqual

{view, layout, region} = require '../src/view'


describe 'view', ->

    it 'declares a view function with v.el undefined', ->
        v = view -> div class:'foo', -> input type:'text'
        # not rendered, so no class
        eql srlz(v.el), '<div></div>'
        v()
        eql srlz(v.el), '<div class="foo"><input type="text"></div>'

    it 'can change the outer tag', ->
        v = view -> p()
        v()
        eql srlz(v.el), '<p></p>'


describe 'layout', ->

    it 'declares a layout with regions specified as classes', ->
        l = layout ->
            div ->
                div region('top')
                div region('bot')
        eql srlz(l.el), '<div><div data-region="top"></div><div data-region="bot"></div></div>'
        eql typeof l.top, 'function'
        eql typeof l.bot, 'function'

    it 'takes views in regions', ->
        l = layout ->
            div class:'outer', ->
                div region('top')
                div region('bot')
        v = view -> div class:'view'
        v()
        l.top v
        eql srlz(l.el), '<div class="outer"><div data-region="top"><div class="view">\
            </div></div><div data-region="bot"></div></div>'
        assert.equal v._rg, l.top # same function

    describe 'operations', ->

        l = v = null
        beforeEach ->
            l = layout -> div ->
                div region('top')
                div region('bot')
            v = view -> div class:'view'
            v()

        it 'moves subviews from old to new region', ->
            l.top v
            eql srlz(l.el), '<div><div data-region="top"><div class="view"></div></div>\
                <div data-region="bot"></div></div>'
            l()
            eql srlz(l.el), '<div><div data-region="top"><div class="view"></div></div>\
                <div data-region="bot"></div></div>'


        it 'move view from region to region', ->
            l.top v
            eql srlz(l.el), '<div><div data-region="top"><div class="view"></div></div>\
                <div data-region="bot"></div></div>'
            l.bot v
            eql srlz(l.el), '<div><div data-region="top"></div><div data-region="bot">\
                <div class="view"></div></div></div>'
