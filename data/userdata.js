'use strict';


var userData = angular.module("userData", []);

// Store User Data
userData.service("userInfo", function(pouchDB){
	this.data = [
	{
		name: "Showreel",
		icon: "fa-video-camera",
		title: "Showreel",
		data: {
			title: "hello"
		}
	},
	{
		name: "Name",
		icon: "fa-user",
		title: "Name",
		data: {
			title: "hello"
		}
	},
	{
		name: "Details",
		icon: "fa-newspaper-o",
		title: "Personal Details",
		data: {
			title: "hello"
		}
	}];
	this.dataActive = 0;
});