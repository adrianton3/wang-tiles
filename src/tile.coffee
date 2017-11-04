'use strict'


bytesPerPixel = 4


get = ({ x, y }) ->
	unless 0 <= x < @size.x and 0 <= y < @size.y
		throw new Error "out of bounds"

	start = (y * @size.x + x) * bytesPerPixel
	[
		@data[start + 0]
		@data[start + 1]
		@data[start + 2]
		@data[start + 3]
	]


getStripe = (start, increment, length) ->
	position = start
	for i in [0...length]
		values = @get position
		position = position.add increment
		values


rotate90 = ->
	data = []

	for x in [0...@size.x]
		for y in [@size.y - 1..0]
			data.push (@get Vec2.make x, y)...

	make data, Vec2.make @size.y, @size.x


rotate180 = ->
	data = []

	for y in [@size.y - 1..0]
		for x in [@size.x - 1..0]
			data.push (@get Vec2.make x, y)...

	make data, @size


rotate270 = ->
	data = []

	for x in [@size.x - 1..0]
		for y in [0...@size.y]
			data.push (@get Vec2.make x, y)...

	make data, Vec2.make @size.y, @size.x


flipVertical = ->
	data = []

	for y in [0...@size.y]
		for x in [@size.x - 1..0]
			data.push (@get Vec2.make x, y)...

	make data, @size


flipHorizontal = ->
	data = []

	for y in [@size.y - 1..0]
		for x in [0...@size.x]
			data.push (@get Vec2.make x, y)...

	make data, @size


equals = ({ data, size }) ->
	@size.equals size and
		@data.every (value, index) -> data[index] == value


proto = {
	get
	getStripe
	rotate90
	rotate180
	rotate270
	flipHorizontal
	flipVertical
	equals
}


make = (data, size) ->
	instance = Object.create proto
	Object.assign instance, { data, size }
	instance


window.TileData ?= {}
Object.assign window.TileData, { make }