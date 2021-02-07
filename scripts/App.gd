extends Control

var nb_points : int = 0

const Point = preload("res://scenes/point.tscn") 
const PointItem = preload("res://scenes/PointElement.tscn")
const Link = preload("res://scenes/Link.tscn")

onready var points = $Graph/Points
onready var poointList = $HBoxContainer/Panel/MarginContainer/VBoxContainer/Panel/ScrollContainer/PointList
onready var links = $Graph/Links
onready var disabled = $Graph/Disabled

func _draw():
	if Globals.linking:
		draw_line(Globals.link_start.position, get_global_mouse_position(), Color.black, 8.0, true)

func _process(delta):
	_update_globals()
	update()
	if Input.is_action_just_pressed("right_click"):
		Globals.linking = false

func get_articulation_points():
	var result = []
	for p in points.get_children():
		#remove point and links
		points.remove_child(p)
		disabled.add_child(p)
		for l in _get_links(p):
			links.remove_child(l)
			disabled.add_child(l)
		
		for p1 in points.get_children():
			if not _is_accessible_from_all(p1):
				result.append(p)
				break
		
		#get back point and links
		disabled.remove_child(p)
		points.add_child(p)
		for l in disabled.get_children():
			disabled.remove_child(l)
			links.add_child(l)
	return result

func _is_accessible_from_all(point):
	for p in points.get_children():
		if p == point:
			continue
		if not _is_accessible(p, point, []):
			return false
	return true

func _add_point(label):
	_reset_highlights()
	var point = Point.instance()
	point.label = label
	point.index = Globals.nb_points
	point.connect("start_link", self, "_on_start_link")
	point.connect("apply_link", self, "_on_apply_link")
	point.connect("mouse_entred_point", self, "_on_mouse_entred_point")
	point.connect("mouse_exited_point", self, "_on_mouse_exited_point")
	points.add_child(point)
	Globals.nb_points += 1
	
	var item = PointItem.instance()
	item.label = label
	item.connect("delete_point", self, "_remove_point")
	item.connect("hide_point", self, "_hide_point")
	poointList.add_child(item)

func _add_link(start, end):
	_reset_highlights()
	for l in links.get_children():
		if (l.start == start and l.end == end) or (l.start == end and l.end == start):
			return
	var link = Link.instance()
	link.start = start
	link.end = end
	links.add_child(link)

func _remove_point(point):
	_reset_highlights()
	for p in points.get_children():
		if p.label == point.label:
			p.queue_free()
			for l in _get_links(p):
				l.queue_free()
			for p1 in points.get_children():
				if p1 != p and p1.index > p.index:
					p1.index -= 1
			break
	point.queue_free()
	Globals.nb_points -= 1

func _remove_link(link):
	_reset_highlights()

func _hide_point(item):
	var point = _get_point_by_label(item.label, disabled)
	if point == null:
		point = _get_point_by_label(item.label, points)
	if point.hidden:
		disabled.remove_child(point)
		points.add_child(point)
		for l in disabled.get_children():
			if (not l is Sprite) and (l.start == point or l.end == point):
				if not (l.start.hidden and l.end.hidden):
					disabled.remove_child(l)
					links.add_child(l)
					l.set_visible(true)
		point.set_visible(true)
	else:
		points.remove_child(point)
		disabled.add_child(point)
		for l in _get_links(point):
			links.remove_child(l)
			disabled.add_child(l)
			l.set_visible(false)
		point.set_visible(false)


func _get_point_by_label(label, from):
	for p in from.get_children():
		if p is Sprite and p.label == label:
			return p

func _on_start_link(start_point):
	Globals.linking = true
	Globals.link_start = start_point

func _on_apply_link(end_point):
	Globals.linking = false
	_add_link(Globals.link_start, end_point)

func _on_mouse_entred_point(point):
	var hided_points = []
	for p in points.get_children():
		if not _is_accessible(p, point, []) and p != point:
			p.set_focus(false)
			hided_points.append(p)
	for l in links.get_children():
		if l.start in hided_points or l.end in hided_points:
			l.set_focus(false)

func _on_mouse_exited_point(point):
	for p in points.get_children():
		p.set_focus(true)
	for l in links.get_children():
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

func _get_links(point):
	var result = []
	for l in links.get_children():
		if l.start == point or l.end == point:
			result.append(l)
	return result

func _get_next_points(point):
	var result = []
	for l in links.get_children():
		if l.start == point:
			result.append(l.end)
		elif l.end == point:
			result.append(l.start)
	return result

func _on_add_point_pressed():
	_add_point(Globals.nb_points)

func _update_globals():
	Globals.center = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	Globals.radius = Vector2(get_viewport_rect().size.y / 2 - 48, 0)

func _reset_highlights():
	for p in points.get_children():
		p.set_highlight(false)

func _on_articulation_pressed():
	for p in get_articulation_points():
		p.set_highlight(true)
