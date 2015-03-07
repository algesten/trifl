{diff, patch, create} = require 'virtual-dom'
{capture, div} = require 'tagg'
{select, OrderedMap} = require './fun'
VDOMOut = require './vdomout'

# global or window, who knows.
glob = null
`glob = global || window`

view = (f) ->
    render = (as...) ->
        # output render function to vtree
        vt = capture new VDOMOut(), f, as
        # patch against previous
        ptch = diff render._vt, vt
        # render into element
        render.el = patch render.el, ptch
        # save new vtree
        render._vt = vt
        render.el
    # placeholder el div
    render.el = create (render._vt = capture new VDOMOut(), div), document:glob.document
    render


# helper to remove child
detach = (view) ->
    return unless view
    delete view._rg
    view?.el?.parentNode?.removeChild view.el

# marks a region as "data-region:<name>"
region = (n) -> "data-region":n

# helper to walk a dom tree
walk = (node, f) -> f node; walk c, f for c in node.childNodes

# an OrderedMap if we are _lazylayout(true)
_lazy = null

# internal id counter to keep layouts apart
lcount = 0

layout = (f) ->

    # this layout's id, used to keep lazy eval apart
    lid = lcount++

    # regions name:view (or name:false initially)
    regions = {}

    # the actual view function
    inner = view f

    # view function wrapper
    render = (as...) ->
        throw new Error("Refusing to render layout when lazy evaluating") if _lazy
        try
            # detach views
            detach vw for name, vw of regions when vw
            # run the original render
            return inner as...
        finally
            # update el
            render.el = inner.el
            # remember old regions
            prevRegions = regions
            # update it all
            makeRegionFunctions()
            # move child views to new regions
            render[name]? vw for name, vw of prevRegions when vw

    makeRegionFunctions = ->
        # reset
        regions = {}
        # pick out data-region="<name>" attributes
        walk render.el, (node) ->

            # region name
            name = node.dataset?.region
            return unless name # not a region node

            regions[name] = false # init marker

            # region function
            render[name] = rg = (vw) ->
                return _lazy.set lid+":"+name, (->rg vw) if _lazy
                # same view in region? no action.
                return if (prev = regions[name]) == vw
                # view is attached to dom? detach.
                detach prev if prev?.el?.parentNode?
                # set new view
                if vw
                    # detach view from current region
                    vw._rg null if vw._rg
                    regions[name] = vw
                    # append the dom node
                    node.appendChild vw.el
                    # and reference to this region
                    vw._rg = render[name]
                else
                    delete regions[name]

    # layouts are prerendered
    render()

    # return render function
    render

_lazylayout = (suspend) ->
    if suspend
        _lazy = new OrderedMap() unless _lazy
    else if _lazy
        l = _lazy
        _lazy = null
        l.get(k)() for k in l.order

module.exports = {view, layout, region, _lazylayout}
