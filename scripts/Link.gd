extends Node2D

const Point = preload("res://scenes/point.tscn")

var start
var end

func set_focus(is_focused):
	var current_alpha = modulate.a
	if is_focused:
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 1), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()
	else:
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 0.1), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()

func _draw():
	draw_line(start.position, end.position, Color.black, 8.00, true)

func _process(delta):
	update()
