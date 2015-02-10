{startswith, indexof} = require './fun'

replaceplus = (s) -> s.replace /\+/g, ' '
decode      = (s) -> decodeURIComponent replaceplus s

# turns a search string ?a=b into an object {a:'b'}
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
    _exec:  null # exec function replaced for every _consume

    constructor: (@win) ->
        @win.addEventListener 'onpopstate', @_check, false
        @loc = {}

    _consume: (loc, pos, query, fun) =>
        sub = loc.substring pos
        spath = @_path
        sexec = @_exec
        @_exec = (f) => f sub, query
        @_path = (p, f) => @_consume loc, pos + p.length, query, f if startswith(sub, p)
        try fun(); finally (@_path = spath; @_exec = sexec)
        return true

    _check: =>
        return false if @loc.pathname == @win.pathname and @loc.search == @win.search
        @_run @win.pathname, @win.search

    _run: (pathname = '/', search = '') ->
        @loc.pathname = pathname
        @loc.search   = search
        q = query if search[0] == '?' then search.substring(1) else search
        @_consume pathname, 0, q, @_route

    navigate: (url) =>
        @win.history.pushState {}, '', url
        @_check()

    route: (f)    => @_route = f
    path:  (p, f) => @_path? p, f
    exec:  (f)    => @_exec? f


# singleton
router = null
do init = ->
    `router = new Router(window)`

module.exports = {route:router.route, path:router.path, navigate:router.navigate}

# expose router/reinit for tests
if global?.__TEST_ROUTER
    module.exports.query = query
    module.exports.router = router
    module.exports.reinit = init
