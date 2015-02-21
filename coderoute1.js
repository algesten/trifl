route(function() {

    // starting from the left,
    // we consume "/contact"
    path('/contact', function() {

        // if current url starts
        // "/contact", this block
        // is executed

        // put contact view in
        // main region
        appview.main(contactview);
    });
});
