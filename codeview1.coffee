articleview = view (articles) ->
  ul ->
    articles.forEach (article) ->
      li article.title, ->
        span class:'desc', article.description

# articleview.el is now a DOM node.





