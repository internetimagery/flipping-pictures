'use strict';
// Edit page. Add in details etc

var app = angular.module("edit", ["ngRoute", "userData", "pouchdb"]);

app.config(function(pouchDBProvider, POUCHDB_METHODS) {
  // Example for pouchdb-authentication
	var authMethods = {
		login: 'qify',
		logout: 'qify',
		getUser: 'qify'
		};
	pouchDBProvider.methods = angular.extend({}, POUCHDB_METHODS, authMethods);
});

// Login information
app.controller("loginPage", ["$scope", "userInfo", function($scope, userInfo){
	$scope.title = "login page";
}]);

// Edit page
app.controller("editPage", ["$scope", "userInfo", function($scope, userInfo){
	$scope.activeIndex = userInfo.dataActive;
	$scope.data = userInfo.data;
	$scope.title = $scope.data[$scope.activeIndex];
}]);

// Navigate through options
app.controller("navigation", ["$scope", "userInfo", function($scope, userInfo){
	$scope.navs = userInfo.data;
	$scope.active = userInfo.dataActive;
	$scope.select = function(index){ $scope.active = index; };
}]);

// Globabl options
app.controller("global", ["$scope", "userInfo", "pouchDB", function($scope, userInfo, pouchDB){
	var db = pouchDB("https://flipping.iriscouch.com/testing");

	$scope.user = "testuser";
	$scope.password = "password";
	$scope.userdata = {};
	$scope.error = "";

	$scope.login = function(){
		if ($scope.user && $scope.password){
			console.log(db);
			db.login($scope.user, $scope.password, function (err, response){
				if (err) {
					if (err.name === 'unauthorized') {
						$scope.error = response;
					} else {
	  					$scope.error = response;
					}
				} else {
					alert("logged in\n" + response);
					$scope.userdata = response;
				}
			});
		}
	};
}]);