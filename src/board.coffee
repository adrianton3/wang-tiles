'use strict'


isInside = ({ x, y }) ->
	0 <= x < @size.x and 0 <= y < @size.y


get = ({ x, y }) ->
	@lines[y][x]


set = ({ x, y }, value) ->
	@lines[y][x] = value
	return


proto = { get, set, isInside }


make = (size) ->
	lines = []

	for i in [0...size.y]
		line = []

		for j in [0...size.x]
			line.push null

		lines.push line

	instance = Object.create proto
	Object.assign instance, { size, lines }
	Object.freeze instance
	instance


window.Board ?= {}
Object.assign window.Board, { make }