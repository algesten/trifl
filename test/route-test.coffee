eql = assert.deepEqual

query = router = reinit = route = path = navigate = null

describe 'route', ->

    beforeEach ->
        global.__TEST_ROUTER = true
        global.window =
            addEventListener: spy ->
            location:
                pathname: '/some/path'
                search:   '?a=b'
            history:
                pushState: spy ->
        {query, reinit} = require '../src/route'
        router = reinit?()
        {route, path, navigate} = router

    afterEach ->
        delete global.window

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
        for k, v of tests
            do (k, v) ->
                it "returns #{JSON.stringify(v)} for '#{k}'", -> eql query(k), v

    describe 'router', ->

        describe '_check', ->

            beforeEach ->
                router._exec = stub().returns true
                router.loc.pathname = '/a/path'
                router.loc.search   = '?panda=true'

            it 'compares pathname/search and does nothing if they are the same', ->
                router.win.pathname = '/a/path'
                router.win.search   = '?panda=true'
                eql router._check(), false
                eql router._exec.callCount, 0

            it 'compares pathname/search and executes _exec if pathname differs', ->
                router.win.pathname = '/another/path'
                router.win.search   = '?panda=true'
                eql router._check(), true
                eql router._exec.callCount, 1
                eql router._exec.args[0], ['/another/path', '?panda=true']

            it 'compares pathname/search and executes _exec if search differs', ->
                router.win.pathname = '/a/path'
                router.win.search   = '?kitten=true'
                eql router._check(), true
                eql router._exec.callCount, 1
                eql router._exec.args[0], ['/a/path', '?kitten=true']

        describe '_exec', ->

            beforeEach ->
                router._consume = spy ->
                router._exec '/a/path', '?panda=true'

            it 'accepts a null pathname', ->
                router._exec null, '?panda=true'
                eql router.loc.pathname, '/'

            it 'accepts a null search', ->
                router._exec '/', null
                eql router.loc.search, ''

            it 'updates the @loc object', ->
                eql router.loc.pathname, '/a/path'
                eql router.loc.search,   '?panda=true'

            it 'calls _consume with the path and parsed query', ->
                eql router._consume.callCount, 1
                eql router._consume.args[0], ['/a/path', 0, {panda:'true'}, router._route]

    describe 'navigate', ->

        beforeEach ->
            router._consume = spy ->
            spy router, '_check'

        it 'window.history.pushState it', ->
            navigate '/a/path?foo=bar'
            eql window.history.pushState.callCount, 1
            eql window.history.pushState.args[0], [{}, '', '/a/path?foo=bar']

        it '_check if the location has changed', ->
            navigate '/a/path?foo=bar'
            eql router._check.callCount, 1

    describe 'route/path', ->

        it 'executes the route set', ->
            route r = spy ->
            router._exec '/a/path', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], ['/a/path', foo:'bar']

        it 'path without match does nothing', ->
            r = null
            route -> path '/item', r = spy ->
            router._exec '/a/path', '?foo=bar'
            eql r.callCount, 0

        it 'path consumes the route further', ->
            r = null
            route -> path '/item', r = spy ->
            router._exec '/item/here', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], ['/here', foo:'bar']

        it 'path in path consumes the route further', ->
            r = null
            route -> path '/item', -> path '/is', r = spy ->
            router._exec '/item/is/there', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], ['/there', foo:'bar']

        it 'path on the same level can match again', ->
            r = null
            route ->
                path '/item', ->
                path '/it', r = spy ->
            router._exec '/item/here', '?foo=bar'
            eql r.callCount, 1
            eql r.args[0], ['em/here', foo:'bar']

        it 'path on the same level can match again after path in path', ->
            r1 = r2 = null
            route ->
                path '/item', -> path '/he', r1 = spy ->
                path '/it', r2 = spy ->
            router._exec '/item/here', '?foo=bar'
            eql r1.callCount, 1
            eql r1.args[0], ['re', foo:'bar']
            eql r2.callCount, 1
            eql r2.args[0], ['em/here', foo:'bar']
