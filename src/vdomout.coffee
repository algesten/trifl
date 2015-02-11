VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'

module.exports = class VDOMOut

    constructor: ->
        # [{name, props, childs, vtrees}]
        @stack = []
        @stack.push @cur = {childs:[], vtree:[]}

    start: ->

    begin: (name, vod, props) ->
        if props.class
            props.className = props.class
            delete props.class
        if vod
            throw new Error "Bad void element root: #{name}" unless @stack.length > 1
            @cur.childs.push {name, props}
        else
            parent = @cur
            @stack.push @cur = {name, props, childs:[], vtrees:[]}
            parent.childs.push @cur

    text: (text) ->
        throw new Error "Bad text element root: #{name}" unless @cur
        @cur.childs.push {text}

    close: (name) ->
        @_childsToVTrees()
        @stack.pop()
        @cur = @stack[@stack.length - 1]

    _childsToVTrees: ->
        @cur.vtrees = @cur.childs.map (c) ->
            if c.text then new VText c.text else new VNode c.name, c.props, c.vtrees

    end: ->
        @_childsToVTrees()
        @cur.vtrees[0]
