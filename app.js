var app = angular.module("app", ["ngRoute"])
.config(["$routeProvider", function($routeProvider){
	$routeProvider.
		when("/login", {
			templateUrl: "views/main.html",
			controller: "login"
		}).
		when("/about", {
			templateUrl: "views/main.html",
			controller: "about"
		}).
		when("/", {
			templateUrl: "views/main.html",
			controller: "main"
		}).
		otherwise({
			redirectTo: "/"
		});
}]);

app.controller("navigation", ["$scope", "$location", function($scope, $location){
	$scope.navs = [{
		name: "Home",
		url: "#/"
	},
	{
		name: "About",
		url: "#/about"
	},
	{
		name: "Login",
		url: "#/login"
	}];
	$scope.loc = $location;
}]);

app.controller("test", ["$scope", function($scope){
	$scope.tests = ["hello","world"];
}]);

app.controller("main", ["$scope", function($scope){
	$scope.title = "MAIN";
	$scope.lists = ["hello", "goodbye", "stuff"];
}]);

app.controller("login", ["$scope", function($scope){
	$scope.title = "LOGIN";
	$scope.lists = ["one", "two", "three", "four", "five"];
}])

app.controller("about", ["$scope", function($scope){
	$scope.title = "ABOUT";
	$scope.lists = ["one", "two", "three", "four", "five"];
}])