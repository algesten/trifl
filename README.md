trifl
=====

[![Build Status](https://travis-ci.org/algesten/trifl.svg)](https://travis-ci.org/algesten/trifl) [![Gitter](https://d378bf3rn661mp.cloudfront.net/gitter.svg)](https://gitter.im/algesten/trifl)

> trifling functional views

Motivation
----------

There are a bunch of user interface libraries breaking new ground into
virtual dom and unidirectional data flow, however they mostly follow a
non-functional programming style. Trifl tries to put functions first.

Check out the tutorial
----------------------

Check out [the tutorial][pages].

Installation
------------

### Installing with Bower

```bash
bower install -S trifl
```

This exposes the global object `trifl`.

#### With coffeescript

Use destructuring assignment to pick out the functions wanted.

```coffee
{action, updated, handle, view, layout, region, route, path, exec, navigate} = trifl

action 'dostuff', arg
```

Install all functions in global scope.

```coffee
trifl.expose window        # All trifl functions are now in window.
trifl.tagg.expose window   # Tons of functions. Use at own risk!
```

Pick functions to install in global scope.

```coffee
trifl.expose window, 'handler', 'action'
trifl.tagg.expose window, 'div', 'p'
```

#### With javascript

Use the functions off the `trifl` object or declare them separate.

```javascript
trifl.action('dostuff', arg);

// or

var action   = trifl.action;
var updated  = trifl.updated;
var handle   = trifl.handle;
var view     = trifl.view;
var layout   = trifl.layout;
var region   = trifl.region;
var route    = trifl.route;
var path     = trifl.path;
var exec     = trifl.exec;
var navigate = trifl.navigate;

action('dostuff', arg);

```

Install all functions in global scope.

```javascript
trifl.expose(window);        // All trifl functions are now in window.
trifl.tagg.expose(window);   // Tons of functions. Use at own risk!
```

Pick functions to install in global scope.

```javascript
trifl.expose(window, 'handler', 'action');
trifl.tagg.expose(window, 'div', 'p');
```

### Installing with NPM

```bash`
npm install -S trifl
```

Overview
--------

Trifl is a functional web client user interface library with a
unidirectional dataflow and a [virtual dom][vdom]. Compared to other
libraries, trifl makes less out of dispatchers, controllers and model
stores.

Trifl consists of three parts: [actions](#actions-and-handlers),
[views](#views-and-layouts) and [router](#router-and-paths). The
*actions* are helper functions to aid decoupling of the application
parts. *Views* are render functions whose purpose is make dom nodes
reflect some model state. The *router* is a utility for organising a
url space into visible views and firing actions as results of url
changes.

Trifl doesn't make components out of *dispatchers* and *controllers* –
they are simple functions, and *models* are nowhere to be found –
implement them any way you want.

There's more theory in [the tutorial][pages].

API
---

The API consists of 10 functions plus [tagg][tagg].

**Action:** [`action`](#action) [`updated`](#updated) [`handle`](#handle)

**View:** [`view`](#view) [`layout`](#layout) [`region`](#region)

**Route:** [`route`](#route) [`path`](#path) [`exec`](#exec) [`navigate`](#navigate)

Tagg is a template library for writing markup as coffeescript.

### Actions and Handlers

#### action

`action(n, a1, a2, ...)`

Dispatches an action named `n` providing variable arguments to the
handler. Only one action can be dispatched at a time apart from
[`updated`](#updated). The intention is to dispatch actions as a result
of user input or asynchronous model updates (such as ajax responses).

`:: string, aa, ab, ... , az -> a`

arg | desc
:---|:----
n   | String name of action to perform. Will call the `handler` for this name.
as  | Variadic arguments forwarded to the handler function.
ret | Return value from the handler function.


##### action example

```coffee
handler 'dostuff', (v) ->   # declare a handler
    console.log "handler says: #{v}"
    return v * 2

r = action 'dostuff', 42    # prints "handler says: 42"
                            # r is now 84
```

### updated

`updated(n)`

Updated is a special class of action, without arguments, that is
allowed to be dispatched during action handling. Updates are used to
to signal that a model has been updated and needs re-rendering in the
views. Updates are deduped and handled, in order, after the current
action is finished.

`:: string -> undefined`

arg | desc
:---|:----
n   | String name of update. Internally this gets transformed to `"update:<n>"`.
ret | always `undefined`

##### updated example

```coffee
# model code
searchModel = {
    setSearchText: (@text) ->
        @requestSearch @text    # request an ajax search with @text
        @state = 'requesting'   # state indicator
        updated 'searchmodel'   # tell the views we have changed
}

# dispatcher code
handler 'setsearchtext', (t) -> # declare a handler
    searchMode.setSearchText t  # propagate action to model

# UI code
action 'setsearchtext', input.value  # action for input changing

```

#### handle

`handle(n, f)`

Declares a handler function `f` for action name `n`. There can only be one
handler for each action and redeclaring the handler will overwrite the
previous. `f` will receive the variadic arguments passed in
[`action`](#action)

We sometimes refer to pure action handlers as "dispatchers" to be
analogous with other libraries.

Handlers for updated actions are prefixed `update:` such that
`update('mymodel')` should be handled with
`handle 'update:mymodel', ->`. Update handlers never receive any
arguments.

We refer to update handlers as "controllers" to describe parallels
with other software libraries.

arg | desc
:---|:----
n   | String name of handler to declare. Use `update:<name>` for update handlers.
f   | Function to declare as handler.
ret | always `f`

##### handle example

```coffee
handle 'stuff', (a) ->
    # do stuff with a

action 'stuff', 42   # pass 42 to handler
```

See [updated example](#updated-example) for how to bind an update handler.



### Views and Layouts

#### view

`v = view(f)`

Creates wrapped view function `v` around `f`. The wrapped function
typically use [`tagg`][tagg] to draw a dom tree from a state
preferably provided as function arguments to the created view
function. These functions are sometimes refered to as "render
functions".

Internally, view functions use [virtual dom][vdom], and the intention
is to "draw a lot". Rather than micro managing view functions to draw
small incremental parts of the page, we rely on virtual dom to make
differential updates (patches) to the actual dom. This means we prefer
to pass entire models to the view functions.

`:: ((aa, ab, ..., az) -> ?) -> ((aa, ab, ..., az) -> el)`

arg | desc
:---|:----
f   | Function to wrap as a view function.
ret | The view function.

##### The created view function

`v(a1, a2, ...)`

The dom element is both the return value when invoking the function
and exposed as a property on the function object (lovely javascript):

```coffee
v = view(f)
el = v(...)  # dom element
v.el         # dom element
```

The initial state of `v.el`, before the view function has ever been
invoked, is an empty placeholder `<div></div>`. Calling the function
can change this to any other tag.

arg | desc
:---|:----
as  | Variadic arguments that will be passed to the inner function `f`.
ret | The dom element rendered.

##### event handlers

Any attribute prefixed `on` will be treated as an event handler and added
to handle events using `node.addEventListener`. I.e. if you want to listen
to `click` or `MyEvent` you would do

```coffee
div onclick: (ev) ->
    # this function is added using node.addEventListener 'click', fn
div onMyEvent: (ev) ->
    # this function is added using node.addEventListener 'MyEvent', fn
```

##### mutation observers

A DOM `MutationObserver` is added using the attribute `observe`

The attribute has two forms

1. With a straight handler function `observe:(mutations) ->`. This
will use defaults observation options: `{childList:true,
attributes:true, attributeOldValue:true, subtree:true}`

2. With an object `observe:{callback:handler, options:{...}}` where
the object has `callback` function for the mutations and `options` to
specify which observe options to use.

```coffee
div observe:{
    options:{characterData:true}
    callback: (mutations) ->
        # deal with mutations
    }
```

##### view example

```coffee
v = view (newslist) ->
    ul class:'newslist', ->
        newslist.forEach (news) ->
            li key:news.id, ->
                a href:"/news/#{news.slugid}", news.title, onclick ->
                    navigate "/news/#{news.slugid}"
                span class="desc", news.description

v.el                             # is currently a placeholder <div></div>
document.body.appendChild v.el   # insert into dom

v(model.newslist)                # draw view. changes placeholder to <ul>...
v.el                             # is now <ul>...</ul>
```

#### layout

`l = layout(f)`

Creates a special class of view function that use
[`region(n)`](#region) in the wrapped `f` function to create "pigeon
holes" in the dom where other views can be inserted.

Layouts *organize* the dom into named placeholders that can display any
other view.

**Note:** Layouts differs from views in that they *always* invoke `f`
  – without any arguments – straight away when created.

`:: ((aa, ab, ..., az) -> ?) -> ((aa, ab, ..., az) -> el)`

arg | desc
:---|:----
f   | Function to wrap as a layout view function.
ret | The layout view function.


##### The created layout function

The created function bevaves exactly like other
[view function](#the-created-view-function) also exposing an `.el`
property.

*However the layout is always rendered upon creation.*

Layouts can take arguments, but must not rely upon them, since the
first invokation, when created, will not provide any.

##### Region functions

Any [`region`](#region) declared in the wrapped function `f` will be
exposed as properties alongside `.el`. These are called *region
functions*.

Notice that `region` is just syntactic sugar. We can manually insert
regions in the layout by using tag attributes `data-region="name"`.

Region functions are lazy inside [`route`](#route) and
[`action`](#action). They don't actuate the change to the dom until
the route/action is finished.

##### layout example

```coffee
l = layout ->
    div ->
        div region('leftnav'), class:'left'
        div region('main'), class:'main'

l.el        # the outer <div>
l.leftnav   # region function for inner div.left
l.main      # region function for inner div.main
```

Region functions are "setters" that take one argument, another view,
and inserts that `view.el` into the region.

```
l = layout -> ...  # create a layout with region('leftnav')
v = view -> ...    # create a view

l.leftnav(v)       # put view in leftnav region
```

#### region

`region(n)`

Special [`tagg`][tagg] attribute that inserts a `data-region="<n>"`
into the dom used by [`layout`](#layout).

`:: string -> {k:v}`

arg | desc
:---|:----
n   | String name of the region function to expose on the [`layout`](#layout) function.
ret | An attribute object `{"data-region":<n>}`

##### region example

See [layout example](#layout-example).



### Router and Paths

#### route

`route(f)`

Declares the route function `f` which will be invoked each time the
url changes. There can only be one such function. The url is
"consumed" and "executed" using nested scoped
[`path`](#path)/[`exec`](#exec) functions.

`:: (() ->) -> undefined`

arg | desc
:---|:----
f   | The one and only route function.
ret | Always `undefined`

##### route usage

The following usage shows how nested `path` declarations creates
"scoped" functions that consumes part of the current url.

```coffee
# the current url is: "/some/path/deep?panda=42"

route ->

    path '/some', ->
        # at this point we "consumed" '/some'
        exec (part, query) ->
            # part is '/path'
            # query is {panda:42}

        path '/deep', ->
            exec (part, query) ->
                # part is ''
                # query is {panda:42}

    # at this point we haven't consumed anything
    exec (part, query) ->
        # part is '/some/path'
        # query is {panda:42}

    path '/another', ->
        # will not be invoked for the current url

```

##### route example

This tries to illustrate a more realistic example, including
[layout](#layout), [region](#region) and [action](#action).

```coffee
isItem = (part, query) -> part?.length > 1     # '' means list

route ->

    appview.top navbar          # show navbar view in top region
    appview.main homeview       # show home view in main region

    path '/news/', ->           # consume '/news/'
        if exec isItem                            # test if this is a news item
            exec (slugid) ->                      # use exec to get slugid from scoped path
                action 'selectarticle', slugid    # fire action to fetch article
                appview.main articleview          # show articleview in main region
        else
            action 'refreshnewslist'
            appview.main newslistview             # show newslist view in main region

    path '/aboutus', ->                           # consume '/aboutus'
        appview.main aboutusview                  # show aboutus view in main region
```

Notice that [region functions](#region-functions) and
[navigate](#navigate) are lazy inside `route`, which means it is fine
to call `appview.main` many times. Only the last call to
`appview.main` will be run when the route function finishes. The same
goes for `navigate`, only the last `navigate` will be used.

#### path

`path(p,f)`

As part of [`route`](#route) declares a function `f` that is invoked
if we "consume" url part `p` of the current (scoped) url.

arg | desc
:---|:----
p   | The string url part to match/consume.
f   | Function to invoke when url part matches.
ret | Always `undefined`

##### path example

See [route usage](#route-usage) and [route example](#route-example).

#### exec

`exec(f)`

As part of [`route`](#route) executes `f` with arguments
`(part,query)` for the current path scope.

arg | desc
:---|:----
f   | Function to invoke with `(part,query)`
ret | The result of the executed function.

##### exec example

See [route usage](#route-usage) and [route example](#route-example).

#### navigate

`navigate(l)`
`navigate(l, false)`

Navigates to the location `l` using [pushState][push] and checks to
see if the url changed in which case the [route function](#route) is
executed.

The function takes an optional second boolean argument that can be
used to supress the execution of the route function.

This function is lazy when used inside [route](#route), only the last
location will be used when the route function finishes.

`:: string -> undefined`
`:: string, boolean -> undefined`

arg | desc
:---|:----
l   | The (string) location to navigate to. Can be relative.
t   | Optional boolean set to false to supress route function triggering.
ret | always `undefined`

##### navigate example

```coffee
# if browser is at "http://my.host/some/where"

navigate 'other'    # changes url to "http://my.host/some/other"
navigate '/news'    # changes url to "http://my.host/news"


navigate '/didnt', false  # changes url to "http://my.host/didnt"
                          # without running the route function
```

Acknowledgements
----------------

Trifl is inspired by:

* [Flux](https://facebook.github.io/flux/) for unidirectional ideas.
* [React](https://facebook.github.io/react/) for the virtual dom,
  although we use another [virtual dom implementation][vdom].
* [Backbone](http://backbonejs.org/) for views and considering url
  routing a core component.
* [Marionette](http://marionettejs.com/) for layouts and regions.

License
-------

The MIT License (MIT)

Copyright © 2015 Martin Algesten

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[tagg]: https://github.com/algesten/tagg
[vdom]: https://github.com/Matt-Esch/virtual-dom
[push]: https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history#The_pushState()_method
[pages]: http://algesten.github.io/trifl/
