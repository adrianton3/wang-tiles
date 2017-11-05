'use strict'


draw = (board, tileSize) ->
	canvas = document.getElementById 'can'
	canvas.width = tileSize.x * board.size.x
	canvas.height = tileSize.y * board.size.y

	context = canvas.getContext '2d'

	for i in [0...board.size.y]
		for j in [0...board.size.x]
			tile = board.get Vec2.make j, i
			if tile?
				context.drawImage tile.image, j * tileSize.x, i * tileSize.y
	return


main = (src, srcSize, outSize) ->
	image = new Image
	image.src = src
	image.addEventListener 'load', ->
		canvas = document.createElement 'canvas'
		canvas.width = image.width
		canvas.height = image.height

		context = canvas.getContext '2d'
		context.drawImage image, 0, 0

		Tileset.getTileset canvas, srcSize
			.then (tileset) ->
				tileSize = Object.assign {}, (tileset.get 't0-0').tileData.size
				outSize ?= Vec2.make(
					window.innerWidth // tileSize.x
					window.innerHeight // tileSize.y
				)

				board = Generator.generate outSize, tileset
				draw board, tileSize
				return

	return


main(
	'3.png'
	Vec2.make 5, 8
)