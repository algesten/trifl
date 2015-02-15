{html5, head, meta, title, link, script, body, div, h1, h2, h3, p, ul,
ol, li, img, figure, figcaption, i, pre, code, a} = require 'tagg'

html5 ->
    head ->
        meta charset:'utf-8'
        title 'trifl - trifling functional views'
        link rel:'stylesheet', href:'css/base.css'
        link rel:'stylesheet', href:'css/prism.css'
        link rel:'stylesheet', href:'css/styles.css'
    body ->

        div class:'top', ->
            div class:'container', ->
                h1 'trifl'
                p 'a functional web client user interface library
                    with a unidirectional dataflow and a virtual dom.'
            div class:'fork', ->
                a href:'https://github.com/algesten/trifl', 'fork me on github'

        div class:'main', ->
            div class:'container', ->
                div class:'docblock', ->

                    figure ->
                        img src:'assets/trifl-flow.svg'
                        figcaption 'figure detailing the flow of a trifl application.'

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
                    p 'Actions can be thought of as really bad events cause they can only
                    have one listener: the handler. Other frameworks
                    talk about "dispatcher" as a component, and whilst trifl doesn\'t
                    have such an component, we encourage to think of action handlers as
                    dispatcher code.'
                    p 'Actions are triggered by input in the user interface or asynchronous
                    server events such as updates and responses to ajax.'

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
                    p 'Only one action can be triggered at a time. It is an error
                    to dispatch another somewhere inside the handler (or model code) and
                    doing so will result in an exception.'
                    p 'There is however another class of actions called updates which
                    are allowed. Updates are used to signal that a model has been updated
                    and requires re-rendering in the views.'

                    h3 'dispatchers and controllers'
                    p 'Handlers come in two variants that work exactly the same, but are
                    mentally separate to know what part of the code they belong in.'

                    ul ->
                        li 'action – ', (-> i 'dispatcher function'), ' (handler)'
                        li 'update – ', (-> i 'controller function'), ' (handler)'

                    p 'Dispatchers are handlers that receive plain actions. Controllers
                    work on the back of models marked as updated during the dispatch
                    of an action.'

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
                          '    updated "articles"\n' +
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
                          '    updated("articles");\n' +
                          '  }\n' +
                          '};'

                div class:'docblock', ->
                    h2 'views'
                    p 'Views render a model state into something the user can see.'


        script src:'js/prism.js'
        div class:'footer', ->
            div class:'container', ->
                p class:'copyright', 'Copyright © 2015 Martin Algesten'
