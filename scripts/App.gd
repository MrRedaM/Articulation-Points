extends Node2D

var nb_points : int = 0

const Point = preload("res://scenes/point.tscn") 
const Link = preload("res://scenes/Link.tscn")


func _draw():
	if Globals.linking:
		draw_line(Globals.link_start.position, get_global_mouse_position(), Color.black, 8.0, true)

func _process(delta):
	_update_globals()
	update()

func _add_point(label):
	var point = Point.instance()
	point.label = label
	point.index = Globals.nb_points
	point.connect("start_link", self, "_on_start_link")
	point.connect("apply_link", self, "_on_apply_link")
	$Points.add_child(point)
	Globals.nb_points += 1

func _remove_point():
	pass

func _on_start_link(start_point):
	Globals.linking = true
	Globals.link_start = start_point

func _on_apply_link(end_point):
	Globals.linking = false
	var link = Link.instance()
	link.start = Globals.link_start
	link.end = end_point
	$Links.add_child(link)

func _on_add_point_pressed():
	_add_point(Globals.nb_points)

func _update_globals():
	Globals.center = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	Globals.radius = Vector2(get_viewport_rect().size.y / 2 - 100, 0)
