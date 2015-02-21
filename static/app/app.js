var b29HelperApp = angular.module('b29HelperApp', [
    'ngRoute',
    'chartControllers'
]);


b29HelperApp.config(['$routeProvider',
    function($routeProvider) {
        $routeProvider.
        when('/charts', {
            templateUrl: 'static/app/partials/chart-list.html',
            controller: 'ChartListCtrl'
        }).
        when('/charts/:chartId', {
            templateUrl: 'static/app/partials/chart-detail.html',
            controller: 'ChartDetailCtrl'
        }).
        otherwise({
            redirectTo: '/charts'
        });
    }
]);

