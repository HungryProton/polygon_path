extends EditorSpatialGizmo

var common = load("res://addons/polygon_path/common.gd")
	
var _show_polygon : bool = false
var _show_grid : bool = false
var _drag_info : PolygonPathDragInfo = PolygonPathDragInfo.new()

func show_polygon(value):
	_show_polygon = value
	redraw()

func show_grid(value):
	_show_grid = value
	redraw()

func consume_drag_info():
	var drag = PolygonPathDragInfo.new()
	PolygonPathDragInfo.assign(drag, _drag_info)
	_drag_info.reset()
	
	var curve = get_spatial_node().curve
	drag.new_pos = curve.get_point_position(drag.index)
	drag.new_in = curve.get_point_in(drag.index)
	drag.new_out = curve.get_point_out(drag.index)
	
	return drag

func set_handle(index, camera, point):
	if _drag_info.index == -1:
		_save_handle_info(index)
	var polygon_path = get_spatial_node()
	var ray_hit_pos = common.intersect_with(polygon_path, camera, point)
	if not ray_hit_pos:
		return
	var local_pos = polygon_path.to_local(ray_hit_pos)
	var count = polygon_path.curve.get_point_count()
	if index < count:
		polygon_path.set_point_position(index, local_pos)
	else:
		var align_handles = Input.is_key_pressed(KEY_SHIFT)
		var i = (index - count)
		var p_index = int(i / 2)
		var base = polygon_path.curve.get_point_position(p_index)
		if i % 2 == 0:
			polygon_path.set_point_in(p_index, local_pos - base)
			if align_handles:
				polygon_path.set_point_out(p_index, -(local_pos - base))
		else:
			polygon_path.set_point_out(p_index, local_pos - base)
			if align_handles:
				polygon_path.set_point_in(p_index, -(local_pos - base))
	redraw()

func redraw():
	clear()
	var polygon_path = get_spatial_node()
	_draw_grid(polygon_path)
	_draw_path(polygon_path.curve)
	_draw_handles(polygon_path.curve)
	_draw_polygon(polygon_path)

func _draw_grid(polygon_path):
	if not _show_grid:
		return
	var grid = PoolVector3Array()
	var size = polygon_path.size
	var center = polygon_path.center
	var resolution = 0.8 # Define how large each square is
	var steps_x = int(size.x / resolution) + 1
	var steps_y = int(size.z / resolution) + 1
	var half_size = size/2
	
	for i in range(steps_x):
		grid.append(Vector3(i*resolution, 0.0, 0.0) - half_size + center)
		grid.append(Vector3(i*resolution, 0.0, size.z) - half_size + center)
	for j in range(steps_y):
		grid.append(Vector3(0.0, 0.0, j*resolution) - half_size + center)
		grid.append(Vector3(size.x, 0.0, j*resolution) - half_size + center)
		
	add_lines(grid, get_plugin().get_material("grid", self), false)

func _draw_path(curve):
	var path = PoolVector3Array()
	var points = curve.get_baked_points()
	var size = points.size() - 1
	
	for i in range(size ):
		path.append(points[i])
		path.append(points[i + 1])
	
	add_lines(path, get_plugin().get_material("path", self), false)

func _draw_handles(curve):
	var handles = PoolVector3Array()
	var square_handles = PoolVector3Array()
	var lines = PoolVector3Array()
	var count = curve.get_point_count()
	if count == 0:
		return
	for i in range(count):
		var point_pos = curve.get_point_position(i)
		var point_in = curve.get_point_in(i) + point_pos
		var point_out = curve.get_point_out(i) + point_pos

		lines.push_back(point_pos)
		lines.push_back(point_in)
		lines.push_back(point_pos)
		lines.push_back(point_out)
		
		square_handles.push_back(point_in)
		square_handles.push_back(point_out)
		handles.push_back(point_pos)
		
	add_handles(handles, get_plugin().get_material("handles", self))
	add_handles(square_handles, get_plugin().get_material("square", self))
	add_lines(lines, get_plugin().get_material("handle_lines", self))

func _draw_polygon(polygon_path):
	if not _show_polygon:
		return
	var polygon = PoolVector3Array()
	var polygon_points = polygon_path.polygon_points
	var size = polygon_points.size() - 1

	for i in range(size):
		var a = polygon_points[i]
		var b = polygon_points[0]
		if(i != size - 1):
			b = polygon_points[i + 1]
		polygon.append(Vector3(a.x, 0.0, a.y))
		polygon.append(Vector3(b.x, 0.0, b.y))
	
	add_lines(polygon, get_plugin().get_material("polygon", self), false)

func _save_handle_info(index):
	var curve = get_spatial_node().curve
	var p_index = index
	var count = curve.get_point_count()
	if index >= count:
		var i = (index - count)
		p_index = int(i / 2)

	_drag_info.old_pos = curve.get_point_position(p_index)
	_drag_info.old_in = curve.get_point_in(p_index)
	_drag_info.old_out = curve.get_point_out(p_index)
	_drag_info.index = p_index
