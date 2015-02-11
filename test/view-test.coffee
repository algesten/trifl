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

describe 'layout', ->

    it 'declares a layout with regions specified as classes', ->
        l = layout top:'.top', bot:'.bot', ->
            div ->
                div class:'top'
                div class:'bot'
        eql typeof l.top, 'function'
        eql typeof l.bot, 'function'

    it 'takes views in regions', ->
        l = layout top:'.top', ->
            div class:'outer', ->
                div class:'top'
        v = view -> div class:'view'
        v()
        l.top v
        eql l.el.childNodes[0].className, 'top'
