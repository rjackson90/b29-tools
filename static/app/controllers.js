var chartControllers = angular.module('chartControllers', ['ngRoute']);

chartControllers.controller('ChartListCtrl', ['$scope', '$http',
    function ($scope, $http) {
        $http.get('api/charts/list.json').success(function(data) {
            $scope.charts = data;
        });
    }
]);

chartControllers.controller('ChartDetailCtrl', ['$scope', '$http',
    function ($scope, $http) {
        $scope.weather_choices = ["Good", "Poor", "Bad"];
        $scope.altitude_choices = ["High", "Medium", "Low"];
        $scope.direction_choices = ["Inbound", "Outbound"];
        $scope.formation_choices = ["In", "Disrupted", "Out"];
        $scope.crew_choices = ["Healthy", "LightWound", "SevereWound", "Dead", "Absent"];

        $scope.master = {};

        $scope.update = function(state) {
            $scope.master = angular.copy(form);
        };

        $scope.reset = function() {
            $scope.form = angular.copy($scope.master);
        };

        $scope.reset();
 
        $scope.severityAsLabel = function(severity) {
            var map = {
                'VeryNeg':'label-danger',
                'Neg':'label-warning',
                'Neutral':'label-info',
                'Pos':'label-success',
                'VeryPos':'label-primary'
            };
            if( severity in map ) {
                return map[severity];
            } else {
                return 'label-default';
            }
        };

        $scope.submit = function(chartId) {
            console.log("Passed chartId: "+chartId);
            request = {'state':$scope.form, 'roll':$scope.form['dice']};
            console.log(request);
            $http.post('/api/charts/'+chartId, request).
                success(function(data, status, headers, config) {
                    console.log("POST success");
                    $scope.newState = data.newState;
                    $scope.results = data.results;
                }).
                error(function(data, status, headers, config) {
                    console.log("POST failure!");
                });
        };
    }
]);


/*
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
*/
