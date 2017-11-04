'use strict'


{
	indexBy
	groupBy
} = Util


getSignature = ({ tileData }) ->
	zero = Vec2.make 0, 0

	up = tileData.getStripe zero, (Vec2.make 1, 0), tileData.size.x
	down = tileData.getStripe (zero.down tileData.size.y - 1), (Vec2.make 1, 0), tileData.size.x
	left = tileData.getStripe zero, (Vec2.make 0, 1), tileData.size.y
	right = tileData.getStripe (zero.right tileData.size.x - 1), (Vec2.make 0, 1), tileData.size.y

	up: up.toString()
	down: down.toString()
	left: left.toString()
	right: right.toString()


getOptions = (tile) ->
	get = tile.get.bind tile
	zero = Vec2.make 0, 0

	weight: (get zero)[0] / 255
	rotations: (get zero.right 1)[0] > 127
	flip:
		vertical: (get zero.right 2)[0] > 127
		horizontal: (get zero.right 3)[0] > 127


getNeighbors = (tilesBySignature, tile) ->
	up = if tilesBySignature.down.has tile.signature.up
		tilesBySignature.down.get tile.signature.up
	else
		[]

	down = if tilesBySignature.up.has tile.signature.down
		tilesBySignature.up.get tile.signature.down
	else
		[]

	left = if tilesBySignature.right.has tile.signature.left
		tilesBySignature.right.get tile.signature.left
	else
		[]

	right = if tilesBySignature.left.has tile.signature.right
		tilesBySignature.left.get tile.signature.right
	else
		[]

	{ up, down, left, right }


getRotations = (tileData, id, { rotations }) ->
	if rotations
		rotated180 = tileData.rotate180()
		if rotated180.equals tileData
			[{ id: "#{id}-90", tileData: tileData.rotate90() }]
		else
			[
				{ id: "#{id}-90", tileData: tileData.rotate90() }
				{ id: "#{id}-180", tileData: rotated180 }
				{ id: "#{id}-270", tileData: tileData.rotate270() }
			]
	else
		[]


getFlipHorizontal = (tileData, id, { flip }) ->
	if flip.horizontal
		flippedHorizontal = tileData.flipHorizontal()
		if flippedHorizontal.equals tileData
			[]
		else
			[{ id: "#{id}-h", tileData: flippedHorizontal }]
	else
		[]


getFlipVertical = (tileData, id, { flip }) ->
	if flip.vertical
		flippedVertical = tileData.flipVertical()
		if flippedVertical.equals tileData
			[]
		else
			[{ id: "#{id}-v", tileData: flippedVertical }]
	else
		[]


getFlips = (tileData, id, { flip }) ->
	flips = [
		(getFlipHorizontal tileData, id, { flip })...
		(getFlipVertical tileData, id, { flip })...
	]

	if flips.length == 2 and flips[0].tileData.equals flips[1].tileData
		[flips[0]]
	else
		flips


getVariants = (tileData, id, { rotations, flip }) ->
	# the flips and rotate-180 can lead to the same tile
	[
		{ id, tileData }
		(getRotations tileData, id, { rotations })...
		(getFlips tileData, id, { flip })...
	]


getTiles = do ->
	padding =
		x: 2
		y: 4

	offset =
		x: 1
		y: 1

	(canvas, size) ->
		context = canvas.getContext '2d'
	
		cellSize = Vec2.make(
			canvas.width // size.x - padding.x
			canvas.height // size.y - padding.y
		)

		tiles = []

		for i in [0...size.x]
			for j in [0...size.y]
				{ data: tileData } = context.getImageData(
					i * (cellSize.x + padding.x) + offset.x
					j * (cellSize.y + padding.y) + offset.y
					cellSize.x
					cellSize.y
				)
	
				original = TileData.make tileData, cellSize

				{ data: optionsData } = context.getImageData(
					i * (cellSize.x + padding.x) + offset.x
					j * (cellSize.y + padding.y) + cellSize.y + offset.y * 2
					cellSize.x
					1
				)

				id = "t#{i}-#{j}"

				options = getOptions TileData.make optionsData, { x: cellSize.x, y: 1 }

				variants = getVariants original, id, options
				variants.forEach (variant) ->
					signature = getSignature variant
					Object.assign variant, options, { signature }
					return

				tiles.push variants...

		tiles


tileDataToImage = ({ data, size }) ->
	canvas = document.createElement 'canvas'
	canvas.width = size.x
	canvas.height = size.y
	context = canvas.getContext '2d'
	imageData = new ImageData (new Uint8ClampedArray data), size.x, size.y
	context.putImageData imageData, 0, 0

	new Promise (resolve, reject) ->
		image = new Image
		image.src = canvas.toDataURL()
		image.addEventListener 'load', ->
			resolve image
			return


getTileset = (canvas, size) ->
	tiles = getTiles canvas, size

	tilesBySignature =
		up: groupBy tiles, (tile) -> tile.signature.up
		down: groupBy tiles, (tile) -> tile.signature.down
		left: groupBy tiles, (tile) -> tile.signature.left
		right: groupBy tiles, (tile) -> tile.signature.right

	tiles.forEach (tile) ->
		tile.neighbors = getNeighbors tilesBySignature, tile
		return

	Promise.all(
		tiles.map (tile) ->
			(tileDataToImage tile.tileData).then (image) -> tile.image = image
	).then -> indexBy tiles, ({ id }) -> id


window.Tileset ?= {}
Object.assign window.Tileset, { getTileset }