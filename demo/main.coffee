'use strict'


draw = (board, tileSize, scale) ->
	canvas = document.getElementById 'can'
	canvas.width = tileSize.x * board.size.x
	canvas.height = tileSize.y * board.size.y

	canvas.style.width = "#{canvas.width * scale}px"
	canvas.style.height = "#{canvas.height * scale}px"

	context = canvas.getContext '2d'

	for i in [0...board.size.y]
		for j in [0...board.size.x]
			tile = board.get Vec2.make j, i
			if tile?
				context.drawImage tile.image, j * tileSize.x, i * tileSize.y
	return


main = (src, srcSize, { outSize, scale }) ->
	image = new Image
	image.src = src
	image.addEventListener 'load', ->
		canvas = document.createElement 'canvas'
		canvas.width = image.width
		canvas.height = image.height

		context = canvas.getContext '2d'
		context.drawImage image, 0, 0

		tileset = Tileset.getTileset canvas, srcSize
		tileSize = Object.assign {}, (tileset.get 't-0-0-id').tileData.size

		result = Validator.validate tileset
		if result.valid
			console.log 'tileset valid'

			outSize ?= Vec2.make(
				window.innerWidth // tileSize.x // scale + 1
				window.innerHeight // tileSize.y // scale + 1
			)

			board = Generator.generate outSize, tileset
			draw board, tileSize, scale
		else
			console.error "tileset invalid; no tile matches #{result.up.id} and #{result.down.id}"

			board = Board.make (Vec2.make 1, 2)
			board.set (Vec2.make 0, 0), tileset.get result.up.id
			board.set (Vec2.make 0, 1), tileset.get result.down.id

			draw board, tileSize, scale

		return
	return


do ->
	options =
		scale: if location.hash then Number(location.hash.slice 1) else 2

	main(
		'5.png'
		Vec2.make 10, 10
		options
	)