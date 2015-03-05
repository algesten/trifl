route ->

    # starting from the left,
    # we consume "/contact"
    path '/contact', ->

        # if current url starts
        # "/contact", this block
        # is invoked

        # put contact view in
        # main region
        appview.main contactview


