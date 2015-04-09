# Create a video player that can be modified.
# Requires vimeo-player-api, js-url
class Video
	sourceUrl: "" # Originial URL
	activeUrl: "" # Modified URL in use
	videoID: ""   # The id of the video in use

	vendor: "" # Which video provider are we using?

	# Set up an empty iframe for video
	constructor: (selector)->
		@playerParent = $(selector)
		@player = $("<iframe frameborder=\"0\"></iframe>").appendTo(@playerParent)
		@player.attr "id", _.uniqueId "player_"

	# Load a new video into the player ONLY VIMEO is supported at the moment
	loadVideo: (url)=>
		path = @_parseURL url
		if path.host.match(/vimeo.com/) and path.path?
			@vendor = "vimeo"
			id = @player.attr "id"
			url = "https://player.vimeo.com/video/#{path.path}?api=1&player_id=#{id}"
			console.log url

	_activateVideo: =>
		if @activeUrl
			@player.attr "src", @activeUrl

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




