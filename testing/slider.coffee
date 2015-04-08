# Initialize the slider
# Requres: colResizable, underscorejs, jquery, froogaloop

class Slider
	sliderWidth: 0 # Width of slider (use for percentages).
	videoDuration: 0 # Duration of the video.
	dragHandles: "<div class='grip'></div>" # Handles used to drag and resize.
	colData: {} # column Data

	events: "scrub" : [], "update" : [] # Store events to be fired

	# Build the slider initially. Slider = parent of slider, data = as below
	constructor: (slider, data)->
		if not data
			data = [
				CLASS : "default"
				CSS : 
					background: "grey"
				CONTENT : "This is a default column",
				RANGE: [0, 100]
			]
		# Create Table for slider
		@slider = $("<table><tr></tr></table>").appendTo $(slider)
		sliderInternal = @slider.find "tr"
		@sliderWidth = @slider.width()

		# Add in columns
		parent = sliderInternal
		for col in data
			parent = @addCol parent, col
		@_activateSlider() # Start the slider

	# Add event callbacks to fire when events happen
	addEvent: (name, callback)=>
		if _.isFunction callback
			@events[name].push callback

	# Fire event when scrubbing the timeline slider. Send out a % value
	_scrubVideo: (e)=>
		percent = e.pageX / @sliderWidth # Form a percentage along the slider TODO: add check for leftmost location
		if percent > 1
			percent = 1
		if percent < 0
			percent = 0
		run(percent) for run in @events["scrub"]

	# Fire event when scrubbing stops and data is updated
	_updateData: (e)=>
		@slider.find "td"
		.each (index, el)=> # For each column in the slider
			id = $(el).attr "id"
			width = $(el).width()
			percent = @sliderWidth / width
			@colData[id] =
				location : percent
		run(@colData) for run in @events["update"]

	# Create a new column. Provide some data to initialize the column.
	# Expecting { CLASS : "myclass", CSS : { background: "red" }, CONTENT : "html stuff" }
	addCol: (parent, data)=>
		column = $("<td></td>")
		.addClass data.CLASS
		.css data.CSS
		.html data.CONTENT
		.attr "id", @_uuid()
		.width ((0.01*(data.RANGE[1] - data.RANGE[0])) * @sliderWidth)

		if parent.tagName is "TD" or parent[0].tagName is "TD"
			$(parent).after column
			newCol = $(parent).next()[0]
		else
			$(parent).append column
			newCol = $(parent).children("td")[0]
		return newCol

	# Divide an existing column to add a new one in the same section
	splitCol: (parent)=>
		@_deactivateSlider() # Stop resizing

		# Get existing column and dimensions
		existing = $(parent).parent "td"
		totalSize = existing.css "width"

		# Create a new column
		newcol = $( addCol existing[0], { "background" : "grey" } )
		half = totalSize.match(/[\d\.]+/) * 0.5

		# Size up new columns
		existing.css "width", "#{half}px"
		newcol.css "width", "#{half}px"

		# Give the new column a unique ID
		id = @_uuid()
		newcol.attr "id", id

		# Restart Slider
		@_activateSlider()

	# Remove a column
	removeCol: (parent)=>
		@_deactivateSlider() # Stop resizing

		parent = $(parent).parent "td"
		id = parent.attr "id"

		# Calculate our missing values
		half = $(parent).css("width").match(/[\d\.]+/) * 0.5
		prev = $(parent).prev()
		next = $(parent).next()

		# Remove column and data
		$(parent).remove()
		delete @colData[id]

		prev.css "width", (prev.css("width") + "#{half}px")
		next.css "width", (next.css("width") + "#{half}px")

		@_activateSlider() # Restart Slider.

	# Generate a unique ID for columns.
	_uuid: =>
		id = _.uniqueId "shot_"
		# If the id exists already.
		if _.findKey @colData, id
			id = @uuid()
		@colData[id] = {}
		return id

	# Activate Slider functionality.
	_activateSlider: =>
		@slider.colResizable
			liveDrag: true
			fixed: true
			gripInnerHtml: @dragHandles
			draggingClass: "grip-drag"
			onDrag: @_scrubVideo
			onResize: @_updateData
			minWidth: 8
	# Disable slider functionality for slider modification
	_deactivateSlider: =>
		@slider.colResizable disable: true 

# Slider should just create the slider columns, activate/deactivate the stuff and scrub the video. Data can be used elsewhere.