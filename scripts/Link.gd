extends Node2D

const Point = preload("res://scenes/point.tscn")

var start
var end
var hidden
var hover = false

func set_focus(is_focused):
	var current_alpha = modulate.a
	if is_focused:
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 1), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()
	else:
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 0.1), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()

func set_visible(visible):
	var current_alpha = modulate.a
	if visible:
		hidden = false
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 1), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()
	else:
		hidden = true
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 0.05), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()

func _draw():
	var color
	if hover:
		color = Color.red
	else:
		color = Color.black
	draw_line(start.position, end.position, color, 8.00, true)

func _process(delta):
	update()
