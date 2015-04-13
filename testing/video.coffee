"use strict";
# Create a video player that can be modified.
# Requires vimeo-player-api, underscore, http://www.youtube.com/iframe_api
# LOAD function has to run before page completely loaded
class Video
	vendor: "" # Which video provider are we using?
	videoDuration: 0 # How long is the video in total?
	aspectRatio: 0 # Ratio to keep the video size correct

	# Set up an empty iframe for video
	constructor: (@source)->
		@update = false

	load: (url, callback)=>
		youtube = url.match /http[s]?:\/\/(?:[^\.]+\.)*(?:youtube\.com\/(?:v\/|watch\?(?:.*?\&)?v=|embed\/)|youtu.be\/)([\w\-\_]+)/i
		if youtube? and youtube[1].length is 11
			@vendor = "youtube"
			videoID = youtube[1]

		vimeo = url.match /(?:https?:\/\/(?:www\.)?)?vimeo.com\/(?:channels\/|groups\/([^\/]*)\/videos\/|album\/(\d+)\/video\/|)(\d+)(?:$|\/|\?)/
		if vimeo?
			@vendor = "vimeo"
			videoID = vimeo[3]
			vimeoPlayer = null

		if @vendor
			if @update
				$.ovoplayer.update {
					type: @vendor
					code: videoID
				}
			else
				@update = true
				$.ovoplayer {
					id: @source
					type: @vendor
					code: videoID
					debug: true
					callback: (player)->
						console.log "CALLED BACK"
						callback()
					}


	# Player controls
	play: ->
		$.ovoplayer.play()
	seek: (time, pause)->
		$.ovoplayer.seek time, (p, o)->
			if pause
				$.ovoplayer.pause()
	first: ->
		$.ovoplayer.first()
	last: ->
		$.ovoplayer.last()
	pause: ->
		$.ovoplayer.pause()
	next: ->
		$.ovoplayer.next()
	previous: ->
		$.ovoplayer.previous()
	repeat: (toggle)->
		$.ovoplayer.repeat toggle
	repeatAll: (toggle)->
		$.ovoplayer.repeatAll toggle

	# Update iframe with a new video
	_update: (vendor, videoID)->
		$.ovoplayer.update {
			type: vendor
			code: videoID
		}

	# Resize player to match width
	_resizeDynamic: =>
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



