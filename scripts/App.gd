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
	point.connect("mouse_entred_point", self, "_on_mouse_entred_point")
	point.connect("mouse_exited_point", self, "_on_mouse_exited_point")
	$Points.add_child(point)
	Globals.nb_points += 1

func _add_link(start, end):
	for l in $Links.get_children():
		if (l.start == start and l.end == end) or (l.start == end and l.end == start):
			return
	var link = Link.instance()
	link.start = start
	link.end = end
	$Links.add_child(link)

func _remove_point():
	pass

func _on_start_link(start_point):
	Globals.linking = true
	Globals.link_start = start_point

func _on_apply_link(end_point):
	Globals.linking = false
	_add_link(Globals.link_start, end_point)

func _on_mouse_entred_point(point):
	var hided_points = []
	for p in $Points.get_children():
		if not _is_accessible(p, point, []) and p != point:
			p.set_focus(false)
			hided_points.append(p)
	for l in $Links.get_children():
		if l.start in hided_points or l.end in hided_points:
			l.set_focus(false)

func _on_mouse_exited_point(point):
	for p in $Points.get_children():
		p.set_focus(true)
	for l in $Links.get_children():
		l.set_focus(true)

func _is_accessible(src, dest, excluded):
	var nexts = _get_next_points(src)
	for p in nexts:
		if p == dest:
			return true
	excluded.append(src)
	for next in nexts:
		if next in excluded:
			continue
		if _is_accessible(next, dest, excluded):
			return true
	return false
	

func _get_next_points(point):
	var result = []
	for l in $Links.get_children():
		if l.start == point:
			result.append(l.end)
		elif l.end == point:
			result.append(l.start)
	return result

func _on_add_point_pressed():
	_add_point(Globals.nb_points)

func _update_globals():
	Globals.center = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	Globals.radius = Vector2(get_viewport_rect().size.y / 2 - 100, 0)
