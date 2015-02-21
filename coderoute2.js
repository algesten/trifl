// current url is /news/panda?format=json

route(function() {

    path('/news/', function() {

        exec(function(remainder, query) {

            // remainder is "panda"
            // query is {format:'json'}

        });
    });
});
