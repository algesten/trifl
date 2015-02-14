{handle, before, after, forward, action} = require '../src/dispatch'

describe.only 'dispatch', ->

    eql = null
    beforeEach -> eql = assert.deepEqual

    it 'executes registered handlers', (done) ->
        b = h = a = null
        before 'panda1', b = spy()
        handle 'panda1', h = spy()
        after  'panda1', a = spy ->
            eql b.callCount, 1
            eql h.callCount, 1
            eql a.callCount, 1
            eql b.args[0], [42]
            eql h.args[0], [42]
            eql a.args[0], [42]
            eql b.calledBefore(h), true
            eql h.calledBefore(a), true
            done()
        action 'panda1', 42

    it 'calls forwards in turn', (done) ->
        f1 = f2 = null
        handle 'panda2', ->
            forward f1 = spy()
            forward f2 = spy()
        after 'panda2', ->
            eql f1.callCount, 1
            eql f2.callCount, 1
            done()
        action 'panda2', 42
