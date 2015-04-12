"use strict";
# Create a video player that can be modified.
# Requires vimeo-player-api, underscore
class Video
	vendor: "" # Which video provider are we using?
	videoDuration: 0 # How long is the video in total?
	aspectRatio: 0 # Ratio to keep the video size correct

	# Set up an empty iframe for video
	constructor: (source, url, callback)->
		@player = $(source)
		@path = @_parseURL url
		@player.html "" # Clear anything from the frame

		if @path.host.match(/vimeo.com/) and @path.path?
			@vendor = "vimeo"
			@_loadVimeo(callback)

		if @path.host.match(/youtu.?be/) and @path.path?
			@vendor = "youtube"
			@_loadYoutube(callback)

	# Scrub to a specific frame.
	scrub: (time)=>
		if 0 < time < @videoDuration
			if @vendor = "vimeo"
				@vimeoAPI.api('seekTo', time);
				@vimeoAPI.api('pause');

	# Load YOUTUBE player
	_loadYoutube: (callback)->
		id = _.uniqueId "player_" # Generate an ID
		url = "http://www.youtube.com/oembed"
		params =
			url: @path.source
			format: "json"

		@_crossDomainLoad "#{url}?#{$.param(params)}", (result)->
			$("#output").text JSON.stringify(result, null, "    ")
		
		console.log "youtube not yet supported"

	# Load up a VIMEO player
	_loadVimeo: (callback)->
		id = _.uniqueId "player_" # Generate an ID
		url = "https://vimeo.com/api/oembed.json" # Base url
		params =
			url: @path.source
			api: true
			player_id: id
			portrait: false
			title: false
			byline: false

		# get video information
		$.get url, params, (data)=>
			# Size up our video
			@aspectRatio = data.height / data.width # Grab the aspect ratio
			@videoDuration = data.duration
			@playerFrame = $(data.html).appendTo(@player) # Add Iframe player
			@playerFrame.attr "id", id
			@_resize()
			@player.resize @_resize # Continue to resize dynamically
			@vimeoAPI = $f @playerFrame[0]
			@vimeoAPI.addEvent "ready", (event, element)=>
				callback()

	# Resize player to match width
	_resize: =>
		height = @player.width() * @aspectRatio
		@playerFrame.width( @player.width() )
		@playerFrame.height( height )
		@player.height( height )


	# Utility for parsing URL's
	_parseURL: (url)->
		dom = document.createElement "a"
		dom.href = url
		{
			source : url
			scheme : dom.protocol.substr 0, dom.protocol.indexOf ":"
			host : dom.hostname
			port : dom.port
			path : dom.pathname.match(/\/?(.*)/)[1]
			query : dom.search.substr dom.search.indexOf( "?" ) + 1
			hash : dom.hash.substr dom.hash.indexOf "#"
		}
	# Load json across domains. Sneaky...
	_crossDomainLoad: (url, callback)->
		$.get "http://query.yahooapis.com/v1/public/yql", {
			q: "select * from json where url = \"#{url}\""
			format: "json"
		}, (data)->
			if data.query.results
				callback data.query.results.json




