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

                h1 'no more trifl'

                p 'Currently I use:'

                ul ->
                    li 'react'
                    li a href:'https://github.com/algesten/react-elem', 'react-elem'
                    li a href:'https://github.com/algesten/refnux', 'refnux'
                    li a href:'https://github.com/algesten/broute', 'broute'

                p 'This is an approxmiation of what trifl tried to be.'
