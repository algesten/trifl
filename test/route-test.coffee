{div} = require 'tagg'
{layout, region, view} = require '../src/view'

describe 'route', ->

    query = router = reinit = route = path = exec = navigate =
    _lazynavigate = _window = null

    beforeEach ->
        global.__TEST_ROUTER = true
        _window = global.window
        global.window =
            addEventListener: spy ->
            location:
                pathname: '/some/path'
                search:   '?a=b'
            history:
                pushState: spy ->
        {query, reinit} = require '../src/route'
        router = reinit?()
        {route, path, exec, navigate, _lazynavigate} = router

    afterEach ->
        global.window = _window

    describe 'query', ->

        empties = [null, undefined, '', false, '&', '&&']
        for v in empties
            do (v) ->
                it "returns {} for '#{String(v)}'", -> eql query(v), {}

        tests =
            '?':       {'?':''}  #yes, correct
            '?&':      {'?':''}  #yes, correct
            '&?':      {'?':''}
            'a':       {a:''}
            '&a':      {a:''}
            '=a':      {a:''}
            '&=a':     {a:''}
            'a=':      {a:''}
            '?a=':     {'?a':''}
            'a=b':     {a:'b'}
            'a==b':    {a:'=b'}
            'a=b=':    {a:'b='}
            'a=b=c':   {a:'b=c'}
            'a=b&=':   {a:'b'}
            '&a=b&':   {a:'b'}
            'a=b&c':   {a:'b',c:''}
            'a=b&c=':  {a:'b',c:''}
            'a=b&c&':  {a:'b',c:''}
            'a=b&c=&': {a:'b',c:''}
            'a=b&c=d': {a:'b',c:'d'}
            'a=%20b':  {a:' b'}
            '%20a=b':  {' a':'b'}
            '&%20a=b': {' a':'b'}
            '&%20a=b&':{' a':'b'}
            'a=1&a=2': {a:['1','2']}
            'a=&a=1':  {a:['','1']}
        for k, v of tests
            do (k, v) ->
                it "returns #{JSON.stringify(v)} for '#{k}'", -> eql query(k), v

    describe 'router', ->

        describe '_check', ->

            beforeEach ->
                router._run = stub().returns true
                router.loc.pathname = '/a/path'
                router.loc.search   = '?panda=true'

            it 'compares pathname/search and does nothing if they are the same', ->
                window.location.pathname = '/a/path'
                window.location.search   = '?panda=true'
                eql router._check(), false
                eql router._run.callCount, 0

            it 'compares pathname/search and invokes _run if pathname differs', ->
                window.location.pathname = '/another/path'
                window.location.search   = '?panda=true'
                eql router._check(), true
                eql router._run.callCount, 1
                eql router._run.args[0], ['/another/path', '?panda=true']

            it 'compares pathname/search and invokes _run if search differs', ->
                window.location.pathname = '/a/path'
                window.location.search   = '?kitten=true'
                eql router._check(), true
                eql router._run.callCount, 1
                eql router._run.args[0], ['/a/path', '?kitten=true']

        describe '_run', ->

            beforeEach ->
                router._consume = spy ->
                router._run '/a/path', '?panda=true'

            it 'accepts a null pathname', ->
                router._run null, '?panda=true'
                eql router.loc.pathname, '/'

            it 'accepts a null search', ->
                router._run '/', null
                eql router.loc.search, ''

            it 'updates the @loc object', ->
                eql router.loc.pathname, '/a/path'
                eql router.loc.search,   '?panda=true'

            it 'calls _consume with the path and parsed query', ->
                eql router._consume.callCount, 1
                eql router._consume.args[0], ['/a/path', 0, {panda:'true'}, router._route]

    describe 'navigate', ->

        beforeEach ->
            spy router, '_check'
            spy router, '_setLoc'

        it 'window.history.pushState it', ->
            navigate '/a/path?foo=bar'
            eql window.history.pushState.callCount, 1
            eql window.history.pushState.args[0], [{}, '', '/a/path?foo=bar']

        it '_check if the location has changed', ->
            navigate '/a/path?foo=bar'
            eql router._check.callCount, 1

        it 'doesnt _check if supressed', ->
            navigate '/b/path?foo=bar', false
            eql router._check.callCount, 0
            eql router._setLoc.callCount, 1

        it 'returns undefined', ->
            r = navigate '/a',
            eql r, undefined

    describe '_lazynavigate', ->

        beforeEach ->
            spy router, '_check'

        describe 'suspends navigation and', ->

            it 'does nothing unless a navigate while suspended', ->
                _lazynavigate true
                _lazynavigate false
                eql window.history.pushState.callCount, 0

            it 'defers the navigation until not suspended', ->
                _lazynavigate true
                navigate '/foo'
                eql window.history.pushState.callCount, 0
                _lazynavigate false
                eql window.history.pushState.callCount, 1
                eql window.history.pushState.args[0], [{}, '', '/foo']

            it 'uses the last navigate', ->
                _lazynavigate true
                navigate '/foo'
                navigate '/bar'
                eql window.history.pushState.callCount, 0
                _lazynavigate false
                eql window.history.pushState.callCount, 1
                eql window.history.pushState.args[0], [{}, '', '/bar']

            it 'also works for navigate(url, false)', ->
                _lazynavigate true
                navigate '/foo'
                navigate '/bar', false
                eql window.history.pushState.callCount, 0
                _lazynavigate false
                eql window.history.pushState.callCount, 1
                eql window.history.pushState.args[0], [{}, '', '/bar']
                eql router._check.callCount, 0

            it 'ignores empty navigate', ->
                _lazynavigate true
                navigate ''
                _lazynavigate false
                eql window.history.pushState.callCount, 0

    describe 'route/path/exec', ->

        it 'outside route, nothing', ->
            path '/', r = spy ->
            exec e = spy ->
            eql r.callCount, 0
            eql e.callCount, 0

        it 'invoke route straight away', ->
            route r = spy()
            eql r.callCount, 1

        it 'route returns undefined', ->
            r = route ->
            eql r, undefined

        it 'path returns undefined', ->
            r = path ->
            eql r, undefined

        it 'exec returns undefined outside route', ->
            r = exec (p, q) -> 42
            eql r, undefined

        it 'exec returns the result of the executed function inside route', ->
            route s = spy ->
                r = exec (p, q) -> 42
                eql r, 42
            eql s.callCount, 1

        it 'invokes the route set', ->
            r = e = null
            window.location =
                pathname:'/a/path'
                search:'?foo=bar'
            route r = spy ->
                exec e = spy ->
            eql r.callCount, 1
            eql r.args[0], []
            eql e.callCount, 1
            eql e.args[0], ['/a/path', foo:'bar']

        it 'invokes to the end and no more', ->
            s = r1 = r2 = e = null
            # default is "/some/path"
            route s = spy ->
                path '/a/path', ->
                    exec e = spy ->
                    path '/', r1 = spy ->
                    path '', r2 = spy ->
            router._run '/a/path', '?foo=bar'
            eql s.callCount, 2
            eql r1.callCount, 0
            eql r2.callCount, 1
            eql r2.args[0], []
            eql e.callCount, 1
            eql e.args[0], ['', foo:'bar']

        it 'path without match does nothing', ->
            r = null
            route -> path '/item', r = spy ->
            router._run '/a/path', '?foo=bar'
            eql r.callCount, 0

        it 'path consumes the route further', ->
            r = null
            route -> path '/item', r = spy ->
            router._run '/item/here', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], []

        it 'path in path consumes the route further', ->
            r = e = null
            route -> path '/item', ->
                path '/is', r = spy ->
                    exec e = spy ->
            router._run '/item/is/there', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], []
            eql e.callCount, 1
            eql e.args[0], ['/there', foo:'bar']

        it 'path on the same level can match again', ->
            r = e1 = e2 = null
            route ->
                path '/item', ->
                    exec e1 = spy ->
                path '/it', r = spy ->
                    exec e2 = spy ->
            router._run '/item/here', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], []
            eql e1.callCount, 1
            eql e1.args[0], ['/here', foo:'bar']
            eql e2.callCount, 1
            eql e2.args[0], ['em/here', foo:'bar']

        it 'path on the same level can match again after path in path', ->
            r1 = r2 = e1 = e2 = null
            route ->
                path '/item', ->
                    path '/he', r1 = spy ->
                        exec e1 = spy ->
                path '/it', r2 = spy ->
                    exec e2 = spy ->
            router._run '/item/here', '?foo=bar'
            eql r1.callCount, 1
            eql r1.args[0], []
            eql r2.callCount, 1
            eql r2.args[0], []
            eql e1.callCount, 1
            eql e1.args[0], ['re', foo:'bar']
            eql e2.callCount, 1
            eql e2.args[0], ['em/here', foo:'bar']

        describe 'lazyview', ->

            it 'suspends layout during route function', ->
                r = null
                l = layout -> div -> div region('reg')
                v1 = view -> div()
                v2 = view -> div()
                spy l, 'reg'
                spy (n = l.el.childNodes[0]), 'appendChild'
                route -> path '/item', ->
                    l.reg v1
                    path '/is', r = spy ->
                        l.reg v2
                router._run '/item/is/there', '?foo=bar'
                eql r.callCount, 1
                eql l.reg.callCount, 2
                eql n.appendChild.callCount, 1

        describe 'lazynavigate', ->

            it 'suspends navigate during route function', ->
                r = null
                route -> path '/item', ->
                    navigate '/foo'
                    path '/is', r = spy ->
                        navigate '/bar'
                router._run '/item/is/there'
                eql r.callCount, 1
                eql window.history.pushState.callCount, 1
                eql window.history.pushState.args[0], [{}, '', '/bar']
