extends Node2D

const Point = preload("res://scenes/point.tscn")

var start
var end

func _draw():
	draw_line(start.position, end.position, Color.black, 8.00, true)

func _process(delta):
	update()
