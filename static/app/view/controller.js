var b29HelperApp = angular.module('b29HelperApp', []);

b29HelperApp.controller('ChartCtrl', function ($scope, $http) {
    $http.get('/charts/charts.json').success(function(data) {
        $scope.charts = data;
    });
});
