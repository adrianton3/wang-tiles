'use strict'


indexBy = (items, getKey) ->
	map = new Map

	items.forEach (item) ->
		key = getKey item
		map.set key, item
		return

	map


groupBy = (items, getKey) ->
	map = new Map

	items.forEach (item) ->
		key = getKey item
		if map.has key
			(map.get key).push item
		else
			map.set key, [item]

		return

	map


window.Util ?= {}
Object.assign window.Util, {
	indexBy
	groupBy
}