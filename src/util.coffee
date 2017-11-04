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


randInt = (max) ->
	Math.floor Math.random() * max


select = (items) ->
	sum = 0
	for item in items
		sum += item.weight

	rand = Math.random() * sum
	partial = 0
	for item in items
		partial += item.weight
		return item if partial > rand

	return


intersect = (first, rest...) ->
	if not first?
		[]
	else if rest.length == 0
		first
	else
		first.filter (candidate) ->
			rest.every (subset) ->
				subset.includes candidate


window.Util ?= {}
Object.assign window.Util, {
	indexBy
	groupBy
	randInt
	select
	intersect
}