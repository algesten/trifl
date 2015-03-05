route ->

    path '/aboutus', ->

        appview.main aboutusview

        path '/history', ->

            # we only invoke
            # this block if
            # current url starts
            # /aboutus/history




