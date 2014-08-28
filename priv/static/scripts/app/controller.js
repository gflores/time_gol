var phonecatApp = angular.module('timeGolApp', []);

phonecatApp.controller('mainCtrl', function ($scope) {
    $scope.phones = [
        {'name': 'Nexus S',
         'snippet': 'Fast just got faster with Nexus S.'},
        {'name': 'Motorola XOOM™ with Wi-Fi',
         'snippet': 'The Next, Next Generation tablet.'},
        {'name': 'MOTOROLA XOOM™',
         'snippet': 'The Next, Next Generation tablet.'}
    ]
    $scope.date = ""
    $scope.universe_name = ""

});

AngularUpdateDate = function(new_date) {
    angular.element($('#main')).scope().date = new_date
    angular.element($('#main')).scope().$apply()
}
AngularUpdateUniverseName = function(universe_name) {
    angular.element($('#main')).scope().universe_name = universe_name
    angular.element($('#main')).scope().$apply()
}
