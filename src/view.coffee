{diff, patch, create} = require 'virtual-dom'
{capture, div} = require 'tagg'
{select} = require './fun'
VDOMOut = require './vdomout'

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
    render.el = create render._vt = capture new VDOMOut(), div
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

layout = (f) ->

    # regions name:view (or name:false initially)
    regions = {}

    # the actual view function
    inner = view f

    # view function wrapper
    render = (as...) ->
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
            render[name] = (vw) ->
                detach prev if (prev = regions[name])?.el?.parentNode?
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

module.exports = {view, layout, region}
