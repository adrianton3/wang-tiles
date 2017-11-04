'use strict'


image = new Image
image.src = '1.png'
image.addEventListener 'load', ->
	canvas = document.getElementById 'can'
	canvas.width = 34 * 2
	canvas.height = 36 * 2

	context = canvas.getContext '2d'
	context.drawImage image, 0, 0

	tileset = Tileset.getTileset canvas, Vec2.make 2, 2

	console.log tileset