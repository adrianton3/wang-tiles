'use strict'


{
	indexBy
	intersect
} = Util


validate = (tileset) ->
	downRightSignatures = indexBy tileset, ({ signature }) -> "#{signature.down}#{signature.right}"
	upLeftTiles = [...downRightSignatures.values()]

	anyMatching = (upTiles, downTiles) ->
		upTiles.some (upTile) ->
			downTiles.some (downTile) ->
				upTile.signature.down == downTile.signature.up

	for upLeftTile in upLeftTiles
		downLeftTiles = upLeftTile.neighbors.down

		for downLeftTile in downLeftTiles
			upRightTiles = upLeftTile.neighbors.right
			downRightTiles = downLeftTile.neighbors.right

			if not anyMatching upRightTiles, downRightTiles
				return {
					valid: false
					up: upLeftTile
					down: downLeftTile
				}

	{
		valid: true
	}


window.Validator ?= {}
Object.assign window.Validator, {
	validate
}