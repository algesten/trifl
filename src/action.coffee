{_lazylayout} = require './view'

# singleton {name:handler}
handlers = {}

# register a handler
handle = (name, handler) -> handlers[name] = handler

# name of only one action executing at a time
current = null
# updated to happen once current is finished
updated = {}

# execute an action
action = (name, as...) -> doAction name, as

updated = (name) ->
    qname = "update:#{name}"
    throw new Error "Rejected (#{qname}) outside action" unless current
    throw new Error "Rejected (#{qname}) during updates for: #{current}" unless updated
    updated[qname] = true
    return undefined

doAction = (name, as) ->
    throw new Error "Rejected (#{name}) during action: #{current}" if current
    try
        current = name
        _lazylayout true
        # return value of the handler
        return handlers[name]? as...
    finally
        # have local copy, reject further updated
        _updated = updated
        updated = null
        try
            handlers[qname]?() for qname of _updated
        finally
            # new updated receiver and current action is done
            updated = {}
            current = null
            _lazylayout false

module.exports = {handle, action, updated}
