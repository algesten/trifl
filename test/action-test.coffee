{handle, action, updated} = require '../src/action'

describe 'action', ->

    it 'performs with no handlers', ->
        action 'no one is listening'
        action 'no one is listening'

    it 'can have a handler', ->
        handle 'dostuff', s = spy()
        action 'dostuff'
        eql s.callCount, 1

    it 'can pass arguments', ->
        handle 'dostuff', s = spy()
        action 'dostuff', 1, 2, 3
        eql s.callCount, 1
        eql s.args[0], [1,2,3]

    it 'refuses to do action in action', ->
        handle 'dostuff', s = spy ->
            assert.throws (->action 'wont work'), 'Rejected (wont work) during action: dostuff'
        action 'dostuff'
        eql s.callCount, 1

    it 'receives the return value of the handler', ->
        handle 'dostuff', (v) -> v * 2
        r = action 'dostuff', 42
        eql r, 84

describe 'handle', ->

    it 'registers exactly on handler function', ->
        handle 'dothings', assert.fail
        handle 'dothings', s = spy()
        action 'dothings'
        eql s.callCount, 1

    it 'returns the function declared', ->
        f = ->
        r = handle 'dothing', f
        assert.equal r, f

describe 'updated', ->

    it 'is not allowed outside handlers', ->
        assert.throws (->updated 'nope'), 'Rejected (update:nope) outside action'

    it 'ignores non handled updates', ->
        handle 'dostuff', -> updated 'ignore me'
        action 'dostuff'

    it 'can invoke multiple updates', ->
        handle 'dostuff', ->
            updated 'one change'
            updated 'another change'
        handle 'update:one change', s1 = spy()
        handle 'update:another change', s2 = spy()
        action 'dostuff'
        eql s1.callCount, 1
        eql s2.callCount, 1

    it 'executes after the action handler', ->
        c1 = spy()
        c2 = spy()
        handle 'dostuff', s1 = spy ->
            updated 'it changed', 'ignored'
            c1()
        handle 'update:it changed', s2 = spy()
        action 'dostuff'
        c2()
        eql s1.callCount, 1
        eql c1.callCount, 1
        eql s2.callCount, 1
        eql c2.callCount, 1
        assert.ok c1.calledAfter s1
        assert.ok s2.calledAfter c1
        assert.ok c2.calledAfter c1

    it 'only executes once', ->
        handle 'dostuff', ->
            updated 'it changed'
            updated 'it changed'
        handle 'update:it changed', s = spy()
        action 'dostuff'
        eql s.callCount, 1

    it 'rejects actions in updates', ->
        handle 'dostuff', ->
            updated 'a change'
        handle 'update:a change', s = spy ->
            assert.throws (->action 'do more stuff'),
                'Rejected (do more stuff) during action: dostuff'
        action 'dostuff'
        eql s.callCount, 1

    it 'rejects updates in updates', ->
        handle 'dostuff', ->
            updated 'a change'
        handle 'update:a change', s = spy ->
            assert.throws (->updated 'another change'),
                'Rejected (update:another change) during updates for: dostuff'
        action 'dostuff'
        eql s.callCount, 1

    it 'returns undefined', ->
        handle 'dostuff', ->
            r = updated 'a change'
            eql r, undefined
        handle 'update:a change', s = spy ->
            return 42 # should never be received
        action 'dostuff'
        eql s.callCount, 1
