I          = (a) -> a
builtin    = I.bind.bind I.call
startswith = (s, i) -> s.slice(0, i.length) == i
indexof    = builtin String::indexOf
concat     = (as...) -> [].concat as...
mixin      = (os...) -> r = {}; r[k] = v for k, v of o for o in os; r

select = (node, sel) ->
    doc = node.ownerDocument unless node.parentNode
    try
        doc.body.appendChild node if doc
        switch sel[0]
            when '.' then node.getElementsByClassName sel[1..]
            when '#' then node.getElementById sel[1..]
            else node.getElementsByTagName sel
    finally
        doc.body.removeChild node if doc

class OrderedMap
    constructor: ->
        @order = []
        @map = {}
    set: (k, v) ->
        @order.push k unless @map.hasOwnProperty(k)
        @map[k] = v
    get: (k) -> @map[k]


expose = (exp, guard) -> (obj, funs...) ->
    if funs?.length
        obj[k] = exp[k] for k in funs
    else unless obj[guard]
        obj[k] = v for k, v of exp when k.indexOf("_") != 0
        obj[guard] = true
    exp


module.exports = {startswith, indexof, select, concat, mixin, OrderedMap, expose}
