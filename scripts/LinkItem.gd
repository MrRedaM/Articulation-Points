extends Panel

var start
var end

signal delete_link(link)
signal hover_link_item(link)
signal exit_link_item(link)

func _ready():
	$MarginContainer/HBoxContainer/StartLabel.text = start.label
	$MarginContainer/HBoxContainer/EndLabel.text = end.label


func _on_TextureButton_pressed():
	emit_signal("delete_link", self)


func _on_LinkItem_mouse_entered():
	emit_signal("hover_link_item", self)



func _on_LinkItem_mouse_exited():
	emit_signal("exit_link_item", self)


func _on_TextureButton_mouse_entered():
	emit_signal("hover_link_item", self)


func _on_TextureButton_mouse_exited():
	emit_signal("exit_link_item", self)
