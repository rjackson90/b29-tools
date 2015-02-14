var b29HelperApp = angular.module('b29HelperApp', []);

b29HelperApp.controller('ChartCtrl', function ($scope, $http) {
    $http.get('/charts/list.json').success(function(data) {
        $scope.charts = data;
    });
});

b29HelperApp.controller('WeatherInZoneCtrl', function($scope, $http) {
    $scope.weather_choices = ["Good", "Poor", "Bad"];
    $scope.altitude_choices = ["High", "Medium", "Low"];
    $scope.direction_choices = ["Inbound", "Outbound"];

    $scope.master = {};

    $scope.update = function(state) {
        $scope.master = angular.copy(state);
    };

    $scope.reset = function() {
        $scope.state = angular.copy($scope.master);
    };

    $scope.reset();

    $scope.submit = function() {
        request = {'state':$scope.state, 'roll':$scope.dice};
        $http.post('/charts/4-2', request).
            success(function(data, status, headers, config) {
                alert("POST Success???");
                console.log(status);
                console.log(data);
                $scope.newState = data.newState;
                $scope.results = data.results;
            }).
            error(function(data, status, headers, config) {
                console.log(request);
                console.log(status);
                console.log(data);
                alert("POST failure!!!");
            });
    };
});
