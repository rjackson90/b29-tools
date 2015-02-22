var b29HelperApp = angular.module('b29HelperApp', [
    'ngRoute',
    'chartControllers'
]);

b29HelperApp.config(['$routeProvider',
    function($routeProvider) {
        $routeProvider.
        when('/charts/default', {
            templateUrl: 'static/app/partials/chart-default.html',
        }).
        when('/charts/4-2', {
            templateUrl: 'static/app/partials/chart-4-2.html',
        }).
        when('/charts/4-3', {
            templateUrl: 'static/app/partials/chart-4-3.html',
        }).
        otherwise({
            redirectTo: '/charts/default'
        });
    }
]);

