{html5, head, meta, title, link, script, body, div, h1, h2, h3, p, ul,
ol, li, img, figure, figcaption, i, b, pre, code, a} = require 'tagg'

fs = require 'fs'
read = (f) -> fs.readFileSync f, encoding:'utf8'

html5 ->
    head ->
        meta charset:'utf-8'
        meta "http-equiv":"X-UA-Compatible", content:"IE=edge"

        title 'trifl - trifling functional views'

        meta name:"viewport", content:"width=device-width, initial-scale=1.0"

        link rel:'stylesheet', href:'css/base.css'
        link rel:'stylesheet', href:'css/prism.css'
        link rel:'stylesheet', href:'css/styles.css'
    body ->

        div class:'top', ->
            div class:'container', ->

                h1 'trifl'

                p 'a functional web client user interface library with
                    a unidirectional dataflow and a virtual dom.'

                p 'Trifl provides some simple ', (->i 'functions'), ' to structure
                web applications.
                There are ', (->b 'actions'), ' to aid a unidirectional data flow,
                ', (->b ' views'), ' to visualize your model state as it changes
                and ', (->b 'router'), ' to glue the url to actions and views.'

                p 'Discuss ', (->a href:'https://gitter.im/algesten/trifl', 'trifl
                on gitter'), ',
                read the ', (->a href:'https://github.com/algesten/trifl#api', 'api
                docs'), ',
                review the ', (->a href:'https://github.com/algesten/trifl', 'code
                on github'), ' and
                report ', (->a href:'https://github.com/algesten/trifl/issues', 'issues on
                github'), '.'

            div class:'buttons', ->
                a class:'button', href:'https://github.com/algesten/trifl#installation', ->
                    'installation'
                a class:'button', href:'https://github.com/algesten/trifl#api', ->
                    'api docs'
                a class:'button fork', href:'https://github.com/algesten/trifl', 'fork me on github'

        div class:'main', ->
            div class:'container', ->
                div class:'docblock', ->

                    figure ->
                        img src:'assets/trifl-flow.svg'
                        figcaption 'figure detailing the flow of a trifl application.'

                    h3 'no async'

                    p 'Trifl does not have callback or asynchronous
                    methods. Everything from view rendering to routing
                    is done synchronously.'

                    h3 'think big'

                    p 'Generally with trifl, it is encouraged to "think big", big actions,
                    big model changes, big view updates. Trifl provides the tools to avoid
                    micro managing model/dom updates.'

                    h2 'three parts', ->
                    p 'There are three parts to trifl:', ->
                        ul ->
                            li (->i 'Actions'), ' are helper functions to aid decoupling of
                            application parts in a unidirectional manner.'
                            li (->i 'Views'), ' are render functions whose purpose are to make
                            dom nodes reflect some model state.'
                            li 'The ', (->i 'router'), ' is a utility for organising a
                            url space into visible views and firing actions as a result of
                            url changes.'

                    h2 'actions'

                    p 'Actions are triggered by input or asynchronous
                    server events such as responses to ajax.'

                    p 'Actions can be thought of as really bad events
                    cause they can only have one listener: the
                    handler. This is one part of "thinking big".
                    Traditional events encourage micro state changes
                    with multiple listeners scattered througout the
                    code. In medium to large applications it quickly
                    become very hard to get an overview of all things
                    happening as a result of such an event.'

                    p 'In trifl there is only one action handler per
                    action, and, in line with unidirectional thinking,
                    its only responsibility is to propagate the action
                    to the model.'

                    p 'Other frameworks talk about "dispatcher" as a
                    component, and whilst trifl doesn\'t have an
                    explicit such an component, we encourage to think
                    of action handlers as dispatcher code.'

                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->
                        p 'Declare a dispatcher function'
                        pre -> code class:'language-coffeescript', ->
                          'handler "selectarticle", (articleid) ->\n' +
                          '    # action updates the model\n' +
                          '    model.articles.requestArticle(articleid)\n\n'
                        p 'Trigger an action'
                        pre -> code class:'language-coffeescript', ->
                          'action "selectarticle", "slugattack01"'
                    div class:'col col-6 mobile-full', ->
                        p 'Declare a dispatcher function'
                        pre -> code class:'language-javascript', ->
                          'handler("selectarticle", function(articleid) {\n' +
                          '    // action updates the model\n' +
                          '    model.articles.requestArticle(articleid);\n' +
                          '});'
                        p 'Trigger an action'
                        pre -> code class:'language-javascript', ->
                          'action("selectarticle", "slugattack01");'

                div class:'docblock', ->

                    p 'Only one action can be triggered at a time. It
                    is an error to dispatch another somewhere inside
                    the handler (or model code executed by the
                    handler) and doing so will result in an
                    exception.'

                    p 'There is however another class of actions
                    called ', (->i 'updates'), ' that are
                    allowed. Updates are used to signal that a model
                    has been updated and requires re-rendering in the
                    views.'

                    h3 'dispatchers and controllers'

                    p 'Handlers come in two variants that work exactly
                    the same, but are mentally separate to know what
                    part of the code they belong in.'

                    ul ->
                        li 'action – ', (-> i 'dispatcher function'), ' (handler)'
                        li 'update – ', (-> i 'controller function'), ' (handler)'

                    p 'Dispatchers are handlers that receive plain
                    actions. Controllers work on the back of models
                    marked as updated during the dispatch of an
                    action.'

                    figure ->
                        img src:'assets/trifl-action2view.svg'
                        figcaption 'figure showing action → module updates → view updates.'

                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->
                        p 'Declare a controller function'
                        pre -> code class:'language-coffeescript', ->
                          'handler "update:articles", ->\n' +
                          '    # rerender views\n' +
                          '    views.articleCount model.articles\n' +
                          '    views.articleView model.articles\n\n'
                        p 'Trigger an update (as part of an action)'
                        pre -> code class:'language-coffeescript', ->
                          'model.articles = {\n' +
                          '  requestArticle: (articleid) =>\n' +
                          '    url = "/get/#{articleid}"\n' +
                          '    $.ajax(url).done (article) ->\n' +
                          '      # trigger action with the update\n'+
                          '      action "gotarticle", article \n' +
                          '    @state = "requesting"\n' +
                          '    update "articles"\n' +
                          '}\n\n\n\n'
                    div class:'col col-6 mobile-full', ->
                        p 'Declare a controller function'
                        pre -> code class:'language-javascript', ->
                          'handler("selectarticle", function(articleid) {\n' +
                          '    // render views\n' +
                          '    views.articleCount(model.articles);\n' +
                          '    views.articleView(model.articles);\n' +
                          '});'
                        p 'Trigger an update (as part of an update)', ->
                        pre -> code class:'language-javascript', ->
                          'model.articles = {\n' +
                          '  requestArticle: function(articleid) {\n' +
                          '    var url = "/get" + articleid";\n' +
                          '    var _this = this;\n' +
                          '    $.ajax(url).done(function(data) {\n' +
                          '      // trigger action with the update\n' +
                          '      action("gotarticle", article);\n' +
                          '    });\n' +
                          '    this.state = "requesting";\n' +
                          '    update("articles");\n' +
                          '  }\n' +
                          '};'

                div class:'docblock', ->

                    h2 'views'

                    p 'Views render a model state into something the user can see.
                    Trifl ships
                    with ', (->a href:'https://github.com/algesten/tagg', 'tagg'), ', configured
                    to deep hook
                    into ', (->a href:'https://github.com/Matt-Esch/virtual-dom', 'virtual-dom'),
                    '.'

                    p 'In views we again "think big" and encourage to
                    render large parts of the screen – entire models –
                    at a time. The virtual dom will figure out the
                    differences, and only make partial real dom
                    changes.'

                    p 'Views are render-functions that are wrapped to
                    provide the virtual-dom-goodness. Using the
                    awesomeness of javascript, we set a property on
                    the created function, ', (->i 'view.el'), '. This
                    is the dom element the view function controls.'

                    p 'Initially, before the view function has ever been
                    invoked, this is a simple <div></div>, but the type
                    can change on first function invokation.'

                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->

                        p 'Create a view function'

                        pre -> code class:'language-coffeescript', ->
                            read 'codeview1.coffee'

                        p 'Render it', ->

                        pre -> code class:'language-coffeescript', ->
                            read 'codeview1b.coffee'


                    div class:'col col-6 mobile-full', ->

                        p 'Create a view function'

                        pre -> code class:'language-javascript', ->
                            read 'codeview1.js'

                        p 'Render it', ->

                        pre -> code class:'language-javascript', ->
                            read 'codeview1b.js'


                div class:'docblock', ->

                    h3 'layouts'

                    p 'Layouts are special views, they provide a means
                    of organizing the dom into named "pigeon holes", called
                    regions, that display other views.'

                    figure ->
                        img src:'assets/layout.svg'
                        figcaption 'figure showing layout and regions.'

                    p 'Layout functions typically don\'t take arguments and
                    are always invoked upon creation.'

                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->

                        p 'Create a layout function'

                        pre -> code class:'language-coffeescript', ->
                            read 'codeview2.coffee'

                        p 'Put a view in a region'

                        pre -> code class:'language-coffeescript', ->
                            read 'codeview2b.coffee'

                    div class:'col col-6 mobile-full', ->

                        p 'Create a layout function'

                        pre -> code class:'language-javascript', ->
                            read 'codeview2.js'

                        p 'Put a view in a region'

                        pre -> code class:'language-javascript', ->
                            read 'codeview2b.js'

                div class:'docblock', ->

                    h2 'router'

                    p 'The router turns the url space into executable
                    code. There is only one route function which use
                    nested path statements to "consume" the current
                    url from left to right.'

                    p 'The route is always executed straight away when
                    set.'


                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->

                        p 'Declare the route function'

                        pre -> code class:'language-coffeescript', ->
                            read 'coderoute1.coffee'

                        p 'Nested path functions'

                        pre -> code class:'language-coffeescript', ->
                            read 'coderoute1b.coffee'

                    div class:'col col-6 mobile-full', ->

                        p 'Declare the route function'

                        pre -> code class:'language-javascript', ->
                            read 'coderoute1.js'

                        p 'Nested path functions'

                        pre -> code class:'language-javascript', ->
                            read 'coderoute1b.js'

                div class:'docblock', ->

                    h3 'exec'

                    p 'To do something useful with the remainder, the
                    not consumed part of the url, we use exec. This
                    executes the given function with two arguments:
                    the remainder and the query object.'

                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->

                        p 'Execute from the current context.'

                        pre -> code class:'language-coffeescript', ->
                            read 'coderoute2.coffee'

                    div class:'col col-6 mobile-full', ->

                        p 'Execute from the current context.'

                        pre -> code class:'language-javascript', ->
                            read 'coderoute2.js'


                div class:'docblock', ->

                    h3 'navigate'

                    p 'navigate does a ', (->
                        a href:'https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history#The_pushState()_method', 'pushState'), ' change
                    of the url. This triggers the route function if the new
                    url differs from the previous.'

                div class:'compare', ->
                    div class:'col col-6 mobile-full', ->

                        p 'Change the url.'

                        pre -> code class:'language-coffeescript', ->
                            read 'coderoute4.coffee'

                    div class:'col col-6 mobile-full', ->

                        p 'Change the url.'

                        pre -> code class:'language-javascript', ->
                            read 'coderoute4.js'


                div class:'docblock endbit', ->

                    p -> i 'go forth, and trifle...'

        script src:'js/prism.js'
        div class:'footer', ->
            div class:'container', ->
                p class:'copyright', 'Copyright © 2015 Martin Algesten'
