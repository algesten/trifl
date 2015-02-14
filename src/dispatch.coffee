{concat} = require './fun'
nextTick = (f) -> setTimeout f, 0

# singleton {name:handler}
handlers = {}

# registers a handler
handle = (name, handler) -> handlers[name] = handler
before = (name, handler) -> handle "before:#{name}", handler
after  = (name, handler) -> handle "after:#{name}",  handler

# name of only one action executing at a time
current = null

# proxy target during action
_forward = null
forward = (f) -> _forward f

# execute an action/forward
action = (name, as...) ->
    throw new Error("Already dispatching #{current}") if current
    nextTick ->
        doAction "before:#{name}", as, ->
            doAction name, as, ->
                doAction "after:#{name}", as
    undefined

# the actual action
doAction = (name, as, cb) ->

    current = name

    return cb?() unless handler = handlers[name]

    todo = []
    _forward = (f2) -> todo.push f2

    execute = (f) -> try f as... finally next()

    next = -> nextTick ->
        if todo.length
            execute todo.shift()
        else
            current = null
            _forward = null
            cb?()

    execute handler # kick it off
    undefined

module.exports = {handle, before, after, forward, action}
