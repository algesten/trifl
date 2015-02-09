
I          = (a) -> a
builtin    = I.bind.bind I.call
startswith = (s, i) -> s.slice(0, i.length) == i
indexof    = builtin String::indexOf

module.exports = {startswith, indexof}
