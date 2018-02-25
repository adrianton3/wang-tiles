'use strict'


{
	indexBy
	groupBy
} = Util


getSignature = (tileData) ->
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


getRotations = (tileData, { rotations }) ->
	return {} unless rotations

	rotated90 = tileData.rotate90()
	if rotated90.equals tileData
		return {}

	rotated180 = tileData.rotate180()
	if rotated180.equals tileData
		return { 'r90': rotated90 }

	{
		'r90': rotated90
		'r180': rotated180
		'r270': tileData.rotate270()
	}


getFlipHorizontal = (tileData, { horizontal }) ->
	return {} unless horizontal

	flippedHorizontal = tileData.flipHorizontal()
	if flippedHorizontal.equals tileData
		{}
	else
		{
			'h': flippedHorizontal
		}


getFlipVertical = (tileData, { vertical }) ->
	return {} unless vertical

	flippedVertical = tileData.flipVertical()
	if flippedVertical.equals tileData
		{}
	else
		{
			'v': flippedVertical
		}


getFlips = (tileData, { flip }) ->
	flips = Object.assign(
		{}
		getFlipHorizontal tileData, flip
		getFlipVertical tileData, flip
	)

	if flips['h']? and flips['v']? and flips['h'].equals flips['v']
		{
			'h': flips['h']
		}
	else
		flips


getVariants = (tileData, options) ->
	rotations = getRotations tileData, options
	flips = getFlips tileData, options

	if options.rotations and options.flip.vertical and options.flip.horizontal
		if rotations['r180']? and flips['h']? and flips['v']?
			Object.assign(
				{}
				rotations
				flips
				{
					'r90-h': rotations['r90'].flipHorizontal()
					'r270-h': rotations['r270'].flipHorizontal()
				}
			)
		else if rotations['r90']? and not rotations['r180']? and flips['h']? and flips['v']?
			Object.assign(
				{}
				rotations
				flips
				{ 'r90-h': rotations['r90'].flipHorizontal() }
			)
		else # if not flips['h']? or not flips['v']?
			rotations
	else
		Object.assign(
			{}
			rotations
			flips
		)


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

				id = "t-#{i}-#{j}"

				options = getOptions TileData.make optionsData, { x: cellSize.x, y: 1 }

				variants = getVariants original, options

				[
					['id', original]
					(Object.entries variants)...
				].forEach ([ key, tileData ]) ->
					signature = getSignature tileData
					tiles.push Object.assign(
						{
							id: "#{id}-#{key}"
							tileData
							signature
						}
						options
					)
					return

		tiles


tileDataToImage = ({ data, size }) ->
	canvas = document.createElement 'canvas'
	canvas.width = size.x
	canvas.height = size.y
	context = canvas.getContext '2d'
	imageData = new ImageData (new Uint8ClampedArray data), size.x, size.y
	context.putImageData imageData, 0, 0
	canvas


getTileset = (canvas, size) ->
	tiles = getTiles canvas, size

	tilesBySignature =
		up: groupBy tiles, (tile) -> tile.signature.up
		down: groupBy tiles, (tile) -> tile.signature.down
		left: groupBy tiles, (tile) -> tile.signature.left
		right: groupBy tiles, (tile) -> tile.signature.right

	tiles.forEach (tile) ->
		tile.neighbors = getNeighbors tilesBySignature, tile
		tile.image = tileDataToImage tile.tileData
		return

	indexBy tiles, ({ id }) -> id


window.Tileset ?= {}
Object.assign window.Tileset, { getTileset }