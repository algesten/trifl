{diff, patch, create} = require 'virtual-dom'
{capture, div} = require 'tagg'
VDOMOut = require './vdomout'

view = (f) ->
    render = (as...) ->
        vt = capture new VDOMOut(), f, as
        ps = diff render._vt, vt
        render.el = patch render.el, ps
        render._vt = vt
    # placeholder el DIV
    render.el = create render._vt = capture new VDOMOut(), div
    render

layout = (f) ->
    render = view f
    render()

module.exports = {view, layout}
