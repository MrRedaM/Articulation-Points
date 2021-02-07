extends Control

var nb_points : int = 0

const Point = preload("res://scenes/point.tscn") 
const PointItem = preload("res://scenes/PointElement.tscn")
const Link = preload("res://scenes/Link.tscn")
const LinkItem = preload("res://scenes/LinkItem.tscn")

onready var points = $Graph/Points
onready var poointList = $HBoxContainer/Panel/MarginContainer/VBoxContainer/Panel/ScrollContainer/PointList
onready var links = $Graph/Links
onready var disabled = $Graph/Disabled
onready var linkList = $HBoxContainer/Panel2/MarginContainer/VBoxContainer2/Panel/ScrollContainer/LinksList

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

func _add_point():
	_reset_highlights()
	var point = Point.instance()
	point.label = Globals.id_count
	point.index = Globals.nb_points
	point.connect("start_link", self, "_on_start_link")
	point.connect("apply_link", self, "_on_apply_link")
	point.connect("mouse_entred_point", self, "_on_mouse_entred_point")
	point.connect("mouse_exited_point", self, "_on_mouse_exited_point")
	points.add_child(point)
	
	var item = PointItem.instance()
	item.label = Globals.id_count
	item.connect("delete_point", self, "_remove_point")
	item.connect("hide_point", self, "_hide_point")
	poointList.add_child(item)
	
	Globals.nb_points += 1
	Globals.id_count += 1

func _add_link(start, end):
	_reset_highlights()
	for l in links.get_children():
		if (l.start == start and l.end == end) or (l.start == end and l.end == start):
			return
	if start == end:
		return
	var link = Link.instance()
	link.start = start
	link.end = end
	links.add_child(link)
	
	var item = LinkItem.instance()
	item.start = start
	item.end = end
	item.connect("delete_link", self, "_remove_link")
	item.connect("hover_link_item", self, "_hover_link_item")
	item.connect("exit_link_item", self, "_exit_link_item")
	linkList.add_child(item)

func _remove_point(point):
	_reset_highlights()
	var p = _get_point_by_label(point.label, points)
	if p == null: p = _get_point_by_label(point.label, disabled)
	for l in _get_links(p):
		_remove_link(l)
	for p1 in points.get_children():
		if p1 != p and p1.index > p.index:
			p1.index -= 1
	point.queue_free()
	p.queue_free()
	Globals.nb_points -= 1

func _remove_link(item):
	_reset_highlights()
	_get_link(item.start, item.end).queue_free()
	#item.queue_free()
	for i in linkList.get_children():
		if (i.start == item.start and i.end == item.end) or (i.start == item.end and i.end == item.start):
			i.queue_free()

func _hover_link_item(item):
	_get_link(item.start, item.end).hover = true

func _exit_link_item(item):
	_get_link(item.start, item.end).hover = false

func _get_link(start, end):
	for l in links.get_children():
		if (l.start == start and l.end == end) or (l.end == start and l.start == end):
			return l
	for l in disabled.get_children():
		if (not l is Sprite):
			if (l.start == start and l.end == end) or (l.end == start and l.start == end):
				return l
	return null

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
	return null

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
	for l in  disabled.get_children():
		if (not l is Sprite) and (l.start == point or l.end == point):
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
	_add_point()

func _update_globals():
	Globals.center = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	Globals.radius = Vector2(get_viewport_rect().size.y / 2 - 48, 0)

func _reset_highlights():
	for p in points.get_children():
		p.set_highlight(false)

func _on_articulation_pressed():
	for p in get_articulation_points():
		p.set_highlight(true)


func _on_delete_all_points_pressed():
	for p in poointList.get_children():
		_remove_point(p)
	Globals.id_count = 0


func _on_delete_all_links_pressed():
	for l in linkList.get_children():
		_remove_link(l)
