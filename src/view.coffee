{diff, patch, create} = require 'virtual-dom'
{capture, div} = require 'tagg'
{select} = require './fun'
VDOMOut = require './vdomout'

view = (f) ->
    render = (as...) ->
        vt = capture new VDOMOut(), f, as
        ptch = diff render._vt, vt
        render.el = patch render.el, ptch
        render._vt = vt
    # placeholder el div
    render.el = create render._vt = capture new VDOMOut(), div
    render

layout = (regions, f) ->
    render = view (as...) ->
        ret = f as...
        # move child views
        render[name]? render["_#{name}"] for name of regions
        ret
    # layouts are prerendered
    render()
    # pick out regions
    for name, sel of regions
        render[name] = do (name, sel) -> (view) ->
            # remember element for re-render
            render["_#{name}"] = view.el
            select(render.el, sel)[0]?.appendChild view.el
    render

module.exports = {view, layout}
