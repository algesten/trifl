route(function() {

    path('/aboutus', function() {

        appview.main(aboutusview);

        path('/history', function() {

            // we only execute
            // this block if
            // current url starts
            // /aboutus/history

        });
    });
});
