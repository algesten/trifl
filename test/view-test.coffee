{div, p, input} = require 'tagg'

{view, layout, region, _lazylayout} = require '../src/view'

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

        it 'moves view from layout to layout', ->
            l1 = layout -> div -> div region('reg')
            l2 = layout -> div -> div region('reg')
            v1 = view -> div class:'v1'
            v1()
            l1.reg v1
            l2.reg v1
            eql srlz(l1.el), '<div><div data-region="reg"></div></div>'
            eql srlz(l2.el), '<div><div data-region="reg"><div class="v1"></div></div></div>'

        it 'doesnt do anything if same view is put in region', ->
            spy (e = l.el.childNodes[0]), 'appendChild'
            eql e.appendChild.callCount, 0
            l.top v
            eql e.appendChild.callCount, 1
            l.top v
            eql e.appendChild.callCount, 1

describe '_lazylayout', ->

    afterEach ->
        _lazylayout false

    it 'suspends region functions', ->
        l = layout -> div -> div region('reg')
        v1 = view -> div class:'v1'
        v2 = view -> div class:'v2'
        v1(); v2()
        _lazylayout true
        l.reg v1
        l.reg v2
        eql srlz(l.el), '<div><div data-region="reg"></div></div>'
        _lazylayout false
        eql srlz(l.el), '<div><div data-region="reg"><div class="v2"></div></div></div>'

    it 'refuses to render layout when lazy', ->
        l = layout -> div -> div region('reg')
        _lazylayout true
        assert.throws (->l()), 'Refusing to render layout when lazy evaluating'
        _lazylayout false

    it 'is fine to set lazy many times', ->
        l = layout -> div -> div region('reg')
        v1 = view -> div class:'v1'
        v1()
        _lazylayout true
        l.reg v1
        _lazylayout true # should keep lazying
        _lazylayout false
        eql srlz(l.el), '<div><div data-region="reg"><div class="v1"></div></div></div>'

    it 'is fine to stop lazy many times', ->
        l = layout -> div -> div region('reg')
        v1 = view -> div class:'v1'
        v1()
        spy l, 'reg'
        _lazylayout true
        l.reg v1
        _lazylayout false
        _lazylayout false
        eql srlz(l.el), '<div><div data-region="reg"><div class="v1"></div></div></div>'
        eql l.reg.callCount, 1

    it 'doesnt confuse many regions of the same name', ->
        l1 = layout -> div -> div region('reg')
        l2 = layout -> div -> div region('reg')
        v1 = view -> div class:'v1'
        v2 = view -> div class:'v2'
        v1(); v2()
        _lazylayout true
        l1.reg v1
        l2.reg v2
        _lazylayout false
        eql srlz(l1.el), '<div><div data-region="reg"><div class="v1"></div></div></div>'
        eql srlz(l2.el), '<div><div data-region="reg"><div class="v2"></div></div></div>'

    it 'lazy moves view from layout to layout', ->
        l1 = layout -> div -> div region('reg')
        l2 = layout -> div -> div region('reg')
        v1 = view -> div class:'v1'
        v1()
        _lazylayout true
        l1.reg v1
        l2.reg v1
        _lazylayout false
        eql srlz(l1.el), '<div><div data-region="reg"></div></div>'
        eql srlz(l2.el), '<div><div data-region="reg"><div class="v1"></div></div></div>'
