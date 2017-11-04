'use strict'


draw = (board) ->
	canvas = document.getElementById 'can'
	canvas.width = 32 * 7
	canvas.height = 32 * 7

	context = canvas.getContext '2d'

	for i in [0...board.size.y]
		for j in [0...board.size.x]
			tile = board.get Vec2.make j, i
			if tile?
				context.drawImage tile.image, j * 32, i * 32
	return


main = ->
	image = new Image
	image.src = '1.png'
	image.addEventListener 'load', ->
		canvas = document.createElement 'canvas'
		canvas.width = 34 * 2
		canvas.height = 36 * 2

		context = canvas.getContext '2d'
		context.drawImage image, 0, 0

		tileset = Tileset.getTileset canvas, Vec2.make 2, 2

		console.log tileset

		board = Generator.generate (Vec2.make 7, 7), tileset

		setTimeout (-> draw board), 1000
	return


main()