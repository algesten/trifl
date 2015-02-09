
{startswith, indexof} = require './fun'

#navigate
#route
#path

replaceplus = (s) -> s.replace /\+/g, ' '
decode      = (s) -> decodeURIComponent replaceplus s

# turns a search string ?a=b into an object
query = (s, ret = {}) ->
    unless s # null, undefined, false, ''
        ret
    else if s[0] == '&'
        query s.substring(1), ret
    else
        [m, key, val] = s.match(/([^&=]+)=?([^&]*)/) || ['']
        ret[decode(key)] = decode(val) if key
        query s.substring(m.length + 1), ret

# encapsulates the router functions
class Router

    loc:   null  # saved location for comparison in _check()
    _route: ->   # saved route function
    _path:  null # path function replaced for every _consume

    constructor: (@win) ->
        @win.addEventListener 'onpopstate', @_check, false
        @loc = {}

    _consume: (loc, pos, query, fun) =>
        sub = loc.substring pos
        saved = @_path
        @_path = (p, f) => @_consume loc, pos + p.length, query, f if startswith(sub, p)
        try fun(sub, query); finally @_path = saved

    _check: =>
        return if @loc.pathname == @win.pathname and @loc.search == @win.search
        @_exec @win.pathname, @win.search

    _exec: (pathname, search) ->
        @loc.pathname = pathname
        @loc.search   = search
        q = query if search[0] == '?' then search.substring(1) else search
        @_consume pathname, 0, q, @_route

    route: (f)    => @_route = f
    path:  (p, f) => @_path p, f


# singleton
`router = new Router(window)`


module.exports = {
    Router, route:router.route, path:router.path, query
}
