applayout = layout(function() {
  div(function() {
    div(region('topnav'));
    div(region('lefnav'));
    div(region('main'));
  });
});

// applayout.el is now the
// outer div

// applayout.topnav,
// applayout.leftnav
// applayout.main are region
// functions
