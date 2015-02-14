trifl
=====

[![Build Status](https://travis-ci.org/algesten/trifl.svg)](https://travis-ci.org/algesten/trifl) [![Gitter](https://d378bf3rn661mp.cloudfront.net/gitter.svg)](https://gitter.im/algesten/trifl)

> trifling functional views

Motivation
----------

There are a bunch of user interface libraries breaking new ground into
virtual dom and unidirectional data flow, however they mostly follow a
non-functional programming style. Trifl tries to put functions first.

Overview
--------

Trifl is a functional web client user interface library with a
unidirectional dataflow and a virtual dom. Compared to other
libraries, trifl makes less out of dispatchers, controllers and model
stores.

![Action Flow](https://algesten.github.io/trifl/assets/trifl-flow.svg)

Trifl consists of three parts: the actions, views and router. The
*actions* are helper functions to aid decoupling of the application
parts. *Views* are render functions whose purpose is make dom nodes
reflect some model state. The *router* is a utility for organising a
url space into which views are visible and firing actions as results
of urls.

Trifl doesn't make components out of *dispatchers* and *controllers* –
they are simple functions, and models are nowhere to be found –
implement them any way you want.

API
---

The API consists of exactly 10 functions plus [tagg][tagg].

### Action

 call                  | description
:----------------------|:-------------
`action(n,a1,a2,...)`  | Dispatches an action named `n` providing variable arguments to the handler. Only one action can be dispatched at a time, apart from `update`.
`update(n)`  | Is a special class of actions that are allowed to be dispatched during action handling. Updates are deduped and handled after the current action is finished.
`handle(n,f)`          | Declares a handler function `f` for an action named `n`. There can only be one such handler per action. The variable arguments in the `action` will be passed to `f`. Update handlers are declared `update:name` and will not be passed any arguments.

### View

 call                  | description
:----------------------|:-------------
`view(f)`              | Declares a view function `f`. Such functions use [`tagg`][tagg] to draw a dom tree from a state preferably provided as function arguments.
`layout(t)`            | Declares a special class of view functions that use `region(n)` in the function to create "pigeon holes" in the dom where other views can be inserted.
`region(n)`            | Special `tagg` attribute that inserts a `data-region="{n}"` into the dom used by `layout`.
[tagg][tagg]           | Is a small library that is used to render a virtual dom inside view functions.

### Router

 call                  | description
:----------------------|:-------------
`route(f)`             | Declares the route function `f` that will be invoked each time the url changes. There can only be one such function.
`path(p,f)`            | As part of `route` declares a function `f` that "consumes" part `p` of the current url and executes the function.
`exec(f)`              | As part of `route` executes `f` passing the current `path` and `query`.
`navigate(l)`          | Navigates the location `l` using push state.

![Action to View](https://algesten.github.io/trifl/assets/trifl-action2view.svg)

[tagg]: https://github.com/algesten/tagg
