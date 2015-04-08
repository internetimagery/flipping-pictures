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
			id = @_uuid()
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
		@slider.find "td"
		.each (index, el)=> # For each column in the slider calculate new range value
			id = $(el).attr "id"
			start = $(el).offset().left - @sliderLocation.left
			end = ($(el).width() + start) / @sliderLocation.width

			start = start / @sliderLocation.width if start # Ensure we're not dividing by zero

			# Clamp between 0 and 1
			start = 0 if start < 0
			end = 1 if end > 1

			# Store new Range values
			@colData[id].RANGE = [start, end]
		run(@colData) for run in @events["update"]

	# Rebuild all collumns based on current data TODO: add ordering check to columns via range
	_rebuildCols: =>
		@_deactivateSlider() # Turn off Slider

		sliderInternal = @slider.find "tr"
		sliderInternal.html("") # Clear out existing columns

		margin = @colMargin / @sliderLocation.width # Minimum size as percentage

		@colSorted = []
		sort = (lastIndex)=> # Sort columns in order
			for key, val of @colData
			#	console.log "index: #{lastIndex}, magin: #{margin}"
				if lastIndex <= val.RANGE[0] < (lastIndex + margin) 
					@colSorted.push key
					sort val.RANGE[1]
		sort 0
		# Build columns
		for id in @colSorted
			column = $("<td></td>")
			.addClass data[id].CLASS
			.css data[id].CSS
			.html data[id].CONTENT
			.attr "id", id
			.width ((data[id].RANGE[1] - data[id].RANGE[0]) * @sliderLocation.width)
			sliderInternal.append column

		@_activateSlider() # Restart Slider

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

	# Remove a column
	removeCol: (id)=>
		id = id.attr "id" if typeof id is "object"

		delete @colData[id]
		@_rebuildCols()

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
			minWidth: @colMargin
	# Disable slider functionality for slider modification
	_deactivateSlider: =>
		@slider.colResizable disable: true 
