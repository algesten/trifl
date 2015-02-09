eql = assert.deepEqual

query = null

describe 'query', ->

    beforeEach ->
        global.window =
            addEventListener: spy ->
        {query} = require '../src/route'

    afterEach ->
        delete global.window

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
