VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'

module.exports = class VDOMOut

    constructor: ->
        # [{name, props, childs, vtrees}]
        @stack = []
        @stack.push @cur = {childs:[], vtree:[]}

    start: ->

    begin: (name, vod, inProps) ->
        props = prepareProps inProps
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


# these special properties should not to be put in the attributes map.
NOT_ATTRIBUTES =
    class: true
    className: true
    key: true
    namespace: true
    style: true

prepareProps = (inp) ->
    props = {}
    # virtual-dom needs all other attributes in a special map.
    attrs = props.attributes = {}
    for k, v of inp
        isData = k[0...5] == 'data-'
        if isData
            props[k] = DataHook(v)
        else
            (if NOT_ATTRIBUTES[k] then props else attrs)[k] = v
    if inp.class
        # we have class
        props.className = inp.class
        delete props.class
    props

# hook for dealing with data-* attributes
class DataHook
    constructor: (@value) ->
        return new DataHook(@value) unless this instanceof DataHook
    hook: (node, name) ->
        node.setAttribute name, @value
        node.dataset = {} unless node.dataset # for jsdom
        node.dataset[camelize(name[5..])] = @value
    unhook: (node, name) ->
        node.removeAttribute name
        delete node.dataset[camelize(name[5..])]

camelize = (n) ->
    n.replace /-(\w)/g, (_,c) -> c.toUpperCase()
