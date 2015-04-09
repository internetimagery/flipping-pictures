# Initialize the slider
# Requres: colResizable, underscorejs, jquery

class Slider
	sliderLocation: {} # Location of slider (use for percentages).

	dragHandles: "<div class='grip'></div>" # Handles used to drag and resize.
	colMargin: 10 # Minimum size of columns
	colData: {} # column Data
	colSorted: []

	events: "scrub" : [], "update" : [] # Store events to be fired

	# Build the slider initially. Slider = parent of slider, data = as below
	# Expecting
		# { "unique id":
		# 	CLASS: "myClass",
		# 	CSS: {
		# 		background: "red"
		# 		},
		# 	CONTENT: "html interior"
		# }
	constructor: (slider, @colData)->
		if not @colData
			id = _.uniqueId "shot_"
			@colData =
				id:
					CLASS : "default"
					CSS : 
						background: "grey"
					CONTENT : "This is a default column. Check log for structure"
					RANGE: [0, 1]
			console.log @colData

		# Create Table for slider
		@slider = $("<table><tr></tr></table>").appendTo $(slider)
		sliderInternal = @slider.find "tr"
		@sliderLocation = @slider.offset()
		@sliderLocation.width = @slider.width()

		# Build Slider
		@_rebuildCols()

	# Add event callbacks to fire when events happen
	addEvent: (name, callback)=>
		if _.isFunction callback
			@events[name].push callback

	# Remove table and clean everything up.
	remove: =>
		@_deactivateSlider()
		@slider.remove()

	# Divide an existing column to add a new one in the same section
	splitCol: (parent, data)=>
		parent = parent.attr "id" if typeof parent is "object" # Grab the ID if given an element, else assume string is id

		multiplier = 0.5 / _.size data # How many columns are we adding? How much do we split em?
		baseRange = @colData[parent].RANGE[1] - @colData[parent].RANGE[0] # The space we have to fit new columns
		segment = baseRange * multiplier # New segment size
		previous = @colData[parent].RANGE[0] + segment # Incriment Sections
		@colData[parent].RANGE[1] = previous # Update parent to new size

		# Modify ranges to fit in extra columns
		for id, col of data
			col.RANGE = []
			col.RANGE.push previous
			previous = previous + segment
			col.RANGE.push previous
			@colData[id] = col

		@_rebuildCols() # Rebuild the slider
		@_updateData() # Update modified data

	# Remove a column
	removeCol: (id)=>
		id = id.attr "id" if typeof id is "object"

		index = @colSorted.indexOf id

		if not index # We are removing the first column.
			if @colSorted.length > 1
				@colData[ @colSorted[1] ].RANGE[0] = 0
			else
				return alert "You cannot remove the last column."
		else # We are removing any other column.
			@colData[@colSorted[index-1]].RANGE[1] = @colData[id].RANGE[1]		

		delete @colData[id]
		@_rebuildCols()
		@_updateData() # Update modified data

	# Fire event when scrubbing the timeline slider. Send out a % value
	_scrubVideo: (e)=>
		percent = (e.pageX - @sliderLocation.left) / @sliderLocation.width # Form a percentage along the slider TODO: add check for leftmost location
		if percent > 1
			percent = 1
		if percent < 0
			percent = 0
		run(percent) for run in @events["scrub"]

	# Fire event when scrubbing stops and data is updated
	_updateData: (e)=>
		lastLoc = 0 # Previous location
		freshData = {} # Refreshing data
		@colSorted = [] # Refreshing column sort
		columns = $(@slider).find "td"
		# Set all ranges as raw pixels
		for col in columns
			id = $(col).attr "id"
			freshData[id] = $.extend({}, @colData[id]) # Copy existing data across
			freshData[id].RANGE[0] = lastLoc
			lastLoc += $(col).width()
			freshData[id].RANGE[1] = lastLoc
			@colSorted.push id # Update sorted columns
		# Turn ranges into percentages
		for id, col of freshData
			for i, px of col.RANGE
				col.RANGE[i] = px / lastLoc
		# Replace existing data with up to date data
		@colData = freshData
		run(@colData) for run in @events["update"]

	# Rebuild all collumns based on current data TODO: add ordering check to columns via range
	_rebuildCols: =>
		@_deactivateSlider() # Turn off Slider

		sliderInternal = @slider.find "tr"
		sliderInternal.html("") # Clear out existing columns

		margin = (@colMargin * 2) / @sliderLocation.width # Minimum size as percentage

		rangeMap = _.map @colData, (value, key, list)-> # Map the ranges
			return value.RANGE[1]
		rangeMap = _.sortBy rangeMap # Sort the ranges

		@colSorted = [] # Reset sorted col
		for map in rangeMap # Sort by range
			for id, val of @colData
				if val.RANGE[1] is map
					@colSorted.push id

		# Build columns
		lastIndex = 0
		for id in @colSorted
			currentIndex = @colData[id].RANGE[1]
			currentIndex = 1 if currentIndex > 1
			column = $("<td></td>")
			.addClass @colData[id].CLASS
			.css @colData[id].CSS
			.html @colData[id].CONTENT
			.attr "id", id
			.width ((currentIndex - lastIndex) * @sliderLocation.width)
			sliderInternal.append column
			lastIndex = currentIndex

		@_activateSlider() # Restart Slider

	# Activate Slider functionality.
	_activateSlider: =>
		@slider.colResizable
			liveDrag: true
			fixed: true
			gripInnerHtml: @dragHandles
			draggingClass: "grip-drag"
			onDrag: @_scrubVideo
			onResize: @_updateData
			minWidth: @colMargin
			hoverCursor: "col-resize"
			headerOnly: true
	# Disable slider functionality for slider modification
	_deactivateSlider: =>
		@slider.colResizable disable: true 
