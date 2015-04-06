// Build an interractive slider to pick video sections
var slider = $("#slider");
var frameSize, froogaloop, videoDuration;

// Remove a collumn
var removeCol = function(e){
	var half, prev, next, element;

	slider.colResizable({disable: true}); // Deactivate slider temporarally

	element = $(this).parent("td");

	half = $(element).css("width").match(/[\d\.]+/) * 0.5;
	prev = $(element).prev();
	next = $(element).next();

	// Remove collumn
	$(element).remove();
	prev.css("width", prev.css("width") + half + "px");
	next.css("width", next.css("width") + half + "px");
	activateSlider();
}

// Adding a new section, and rebuilding colResizable
var splitCol = function(e){
	var totalSize, oldTD, newTD;

	slider.colResizable({disable: true}); // Deactivate slider temporarally

	oldTD = $(this).parent("td");
	totalSize = oldTD.css("width");
	newTD = $(addCol(oldTD[0], {"background":"grey"}));
	var half = totalSize.match(/[\d\.]+/) * 0.5;
	oldTD.css('width', half + "px");
	newTD.css('width', half + "px");
	activateSlider();
}

// Build a new collumn
var addCol = function(element, data){
	var tag, concat, newElement;
	concat = ""; // Form data together
	for(var key in data){
		concat += key + ":" + data[key] + ";";
	}
	var tag = '<td style="'+concat+'"><span class="add"> NEW </span> | <span class="del"> DEL </span></td>';
	// If a TD tag, make new item alongside it
	if(element.tagName === "TD" || element[0].tagName === "TD"){
		$(element).after(tag);
		newElement = $(element).next()[0];
	} else {
		$(element).html(tag);
		newElement = $(element).children('td')[0];
	}
	buildClick(newElement);
	return newElement;
}

// build click event into slider
var buildClick = function(slider){
	var add = $(slider).children('.add')[0];
	var del = $(slider).children('.del')[0];
	$(add).click( splitCol );
	$(del).click( removeCol );
}

// Live data when sliding
var sliderDrag = function(e){
	var time = e.pageX;
	var percent =  time / frameSize ; // duration as percent
	var seekVid = videoDuration * percent;
	froogaloop.api('seekTo', seekVid);
	froogaloop.api('pause');
}
// Update data when sliding stops
var sliderStop = function(e){
	// console.log(e);
}
// Activate slider on section
var activateSlider = function(){
	slider.colResizable({
		liveDrag: true,
		fixed: true,
		gripInnerHtml:"<div class='grip'></div>", 
		draggingClass:"dragging",
		onDrag: sliderDrag,
		onResize: sliderStop,
		minWidth: 8
	});
}

// Build up the slider from data
var buildSlider = function(parent, data){
	var newcol = parent;
	for (var i = data.length - 1; i >= 0; i--) {
		newcol = addCol( newcol, data[i]["style"] );
	}
	activateSlider();
}

// START!
jQuery(document).ready(function($) {
	frameSize = 500; // Max size of the frame

	// Set up vimeo player when ready
	var playerID = $("#player")[0];
	$f(playerID).addEvent("ready", function(event, element){
		alert("event");
		froogaloop = $f(playerID);
		froogaloop.api('getDuration', function (value, player_id) {
			alert("duration");
			videoDuration = value;
			buildSlider($("#slider>tbody>tr"), cols);
		});
	});
	// Some test data
	var cols = [
	{
		"style": {
			"background": "orange",
			"width": "88px"
		}
	},
	{
		"style": {
			"background": "blue",
			"width": "123px"
		}
	},
	{
		"style": {
			"background": "green",
			"width": "289px"
		}
	}];
});