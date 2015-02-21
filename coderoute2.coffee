# current url is /news/panda?format=json

route ->

    path '/news/', ->

        exec (remainder, query) ->

            # remainder is "panda"
            # query is {format:'json'}




