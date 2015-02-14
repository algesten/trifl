# singleton {name:handler}
handlers = {}

# register a handler
handle = (name, handler) -> handlers[name] = handler

# name of only one action executing at a time
current = null
# updates to happen once current is finished
updates = {}

# execute an action
action = (name, as...) -> doAction name, as

update = (name) ->
    qname = "update:#{name}"
    throw new Error "Rejected (#{qname}) outside action" unless current
    throw new Error "Rejected (#{qname}) during updates for: #{current}" unless updates
    updates[qname] = true

doAction = (name, as) ->
    throw new Error "Rejected (#{name}) during action: #{current}" if current
    try
        current = name
        return handlers[name]? as...
    finally
        # have local copy, reject further updates
        _updates = updates
        updates = null
        try
            handlers[qname]?() for qname of _updates
        finally
            # new updates receiver and current action is done
            updates = {}
            current = null

module.exports = {handle, action, update}
