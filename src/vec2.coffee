'use strict'


up = (amount = 1) ->
	make @x, @y - amount


down = (amount = 1) ->
	make @x, @y + amount


left = (amount = 1) ->
	make @x - amount, @y


right = (amount = 1) ->
	make @x + amount, @y


add = ({ x, y }) ->
	make @x + x, @y + y


equals = ({ x, y }) ->
	@x == x and @y == y


proto = { up, down, left, right, add, equals }


make = (x, y) ->
	instance = Object.create proto
	Object.assign instance, { x, y }
	Object.freeze instance
	instance


window.Vec2 ?= {}
Object.assign window.Vec2, { make }