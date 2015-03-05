{startswith, indexof} = require './fun'
{_lazylayout}         = require './view'

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
        if key
            dkey = decode key
            dval = decode val
            if (prev = ret[dkey])?
                arr = if Array.isArray(prev) then prev else ret[dkey] = [prev]
                arr.push decode(val)
            else
                ret[dkey] = dval
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
        @_exec = (f)    => f sub, query
        @_path = (p, f) => @_consume loc, pos + p.length, query, f if startswith(sub, p)
        try fun() finally (@_path = spath; @_exec = sexec)
        return true

    _check: =>
        winloc = @win.location
        return false if @loc.pathname == winloc.pathname and @loc.search == winloc.search
        @_run winloc.pathname, winloc.search

    _run: (pathname = '/', search = '') ->
        @loc.pathname = pathname
        @loc.search   = search
        q = query if search[0] == '?' then search.substring(1) else search
        try
            @_lazynavigate true
            _lazylayout true
            @_consume pathname, 0, q, @_route
        finally
            @_lazynavigate false
            _lazylayout false

    navigate: (url) =>
        if @_lazynav
            @_lazynav = url if url
        else
            @win.history.pushState {}, '', url
            @_check()
        return undefined

    _lazynavigate: (suspend) =>
        if suspend
            @_lazynav = '__NOT'
        else
            url = @_lazynav
            delete @_lazynav
            @navigate url unless url == '__NOT'

    route: (f)    =>
        @_route = f
        #reset
        @loc = {}
        # and start again
        router._check()
        return undefined

    path:  (p, f) => @_path? p, f
    exec:  (f)    => @_exec? f

# singleton
router = null
do init = ->
    `router = new Router(window)`

module.exports = {
    route:router.route, path:router.path, exec:router.exec, navigate:router.navigate,
    _lazynavigate:router._lazynavigate
}

# expose router/reinit for tests
if global?.__TEST_ROUTER
    module.exports.query = query
    module.exports.router = router
    module.exports.reinit = init
