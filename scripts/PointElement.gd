extends Panel

var label : String

signal delete_point(point)
signal hide_point(point)

func _ready():
	$MarginContainer/HBoxContainer/Label.text = label

func is_hidden():
	return $MarginContainer/HBoxContainer/TextureButton.pressed

func set_hide(hide):
	$MarginContainer/HBoxContainer/TextureButton.pressed = hide
	emit_signal("hide_point", self)
	

func _on_delete_button_pressed():
	emit_signal("delete_point", self)


func _on_hide_button_pressed():
	emit_signal("hide_point", self)
