extends Sprite

export var label : String
var index

signal start_link(point)
signal apply_link(point)

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
