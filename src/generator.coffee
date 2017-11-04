'use strict'


{
	randInt
	select
	intersect
} = Util


findValidTiles = (board, position) ->
	up = if board.isInside position.up() then board.get position.up() else null
	down = if board.isInside position.down() then board.get position.down() else null
	left = if board.isInside position.left() then board.get position.left() else null
	right = if board.isInside position.right() then board.get position.right() else null

	subsets = [
		up?.neighbors.down
		down?.neighbors.up
		left?.neighbors.right
		right?.neighbors.left
	].filter (subset) -> subset? and subset.length > 0

	intersect subsets...


#findEmptyCell = (board) ->
#	loop
#		y = randInt board.length
#		x = randInt board[y].length
#
#		return { x, y } unless board[y][x]?


getNeighbors = (board, position) ->
	neighbors = []
	neighbors.push position.left() if position.x > 0
	neighbors.push position.up() if position.y > 0
	neighbors.push position.right() if position.x < board.size.x - 1
	neighbors.push position.down() if position.y < board.size.y - 1
	neighbors


bf = (board, start) ->
	queue = [start]
	tries = 0
	triesMax = 1000

	while tries < triesMax and queue.length > 0
		tries++
		position = queue.shift()
		neighbors = getNeighbors board, position
		for neighbor in neighbors
			if not (board.get neighbor)?
				candidates = findValidTiles board, neighbor
				queue.push neighbor
				board.set neighbor, select candidates

	if tries >= triesMax
		console.log 'bf gave up'

	return


generate = (size, tileset) ->
	board = Board.make size
	board.set (Vec2.make 0, 0), tileset.get 't0-0'
	bf board, Vec2.make 0, 0
	board


window.Generator ?= {}
Object.assign window.Generator, { generate }