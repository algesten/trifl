var articleview = view(function(articles) {
  ul(function() {
    articles.forEach(function(article) {
      li(article.title, function() {
        span({className:'desc'},
          article.description);
      });
    });
  });
});

// articleview.el is now DOM node.
