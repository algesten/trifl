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


srlz = require('jsdom').serializeDocument


layout = (regions, f) ->
    views = {}
    inner = view f
    render = (as...) ->
        try
            # detach views
            detach vw for name, vw of views
            # run the original render
            return inner as...
        finally
            # update el
            render.el = inner.el
            # reset child views
            render[name]? vw for name, vw of views
    # layouts are prerendered
    render()
    # pick out regions
    for name, sel of regions
        render[name] = do (name, sel) -> (vw) ->
            # detach previous view if there
            detach prev if (prev = views[name])?.el?.parentNode?
            # set new view
            if vw
                if regel = select(inner.el, sel)[0]
                    views[name] = vw
                    regel.appendChild vw.el
                    vw._rg = render[name]
            else
                delete views[name]
    render

module.exports = {view, layout}
