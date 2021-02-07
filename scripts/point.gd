extends Sprite

const blue_circle = preload("res://assets/circle_blue.png")
const black_circle = preload("res://assets/circle.png")

export var label : String
var index

signal start_link(point)
signal apply_link(point)
signal mouse_entred_point(point)
signal mouse_exited_point(point)

func set_focus(is_focused):
	var current_alpha = modulate.a
	if is_focused:
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 1), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()
	else:
		$OpacityTween.interpolate_property(self, "modulate", Color(1, 1, 1, current_alpha), Color(1, 1, 1, 0.5), 0.7, Tween.TRANS_EXPO)
		$OpacityTween.start()

func set_highlight(h):
	if h:
		self.texture = blue_circle
	else:
		self.texture = black_circle

func _draw():
	var angle = (2 * PI) / Globals.nb_points
	position = Globals.center + Globals.radius.rotated(angle * index)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()

func _process(delta):
	update()

func update_label():
	$Label.text = label

func _on_Label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if Globals.linking:
				emit_signal("apply_link", self)
			else:
				emit_signal("start_link", self)


func _on_mouse_entered():
	if not Globals.linking:
		emit_signal("mouse_entred_point", self)


func _on_mouse_exited():
	emit_signal("mouse_exited_point", self)
