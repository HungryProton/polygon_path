extends EditorSpatialGizmo

var common = load("res://addons/gm_path/common.gd")

var _show_polygon : bool = false
var _show_grid : bool = false

func show_polygon(value):
	_show_polygon = value
	redraw()

func show_grid(value):
	_show_grid = value
	redraw()

func set_handle(index, camera, point):
	var gm_path = get_spatial_node()
	var ray_hit_pos = common.intersect_with(gm_path, camera, point)
	if not ray_hit_pos:
		return
	var local_pos = gm_path.to_local(ray_hit_pos)
	var count = gm_path.curve.get_point_count()
	if index < count:
		gm_path.set_point_position(index, local_pos)
	else:
		var i = (index - count)
		var p_index = int(i / 2)
		var base = gm_path.curve.get_point_position(p_index)
		if i % 2 == 0:
			gm_path.set_point_in(p_index, local_pos - base)
		else:
			gm_path.set_point_out(p_index, local_pos - base)
	redraw()

func redraw():
	clear()
	var gm_path = get_spatial_node()
	_draw_grid(gm_path)
	_draw_path(gm_path.curve)
	_draw_handles(gm_path.curve)
	_draw_polygon(gm_path)

func _draw_grid(gm_path):
	if not _show_grid:
		return
	var grid = PoolVector3Array()
	var size = gm_path.size
	var center = gm_path.center
	var resolution = 0.5
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

func _draw_polygon(gm_path):
	if not _show_polygon:
		return
	var polygon = PoolVector3Array()
	var polygon_points = gm_path.polygon_points
	var size = polygon_points.size() - 1

	for i in range(size):
		var a = polygon_points[i]
		var b = polygon_points[0]
		if(i != size - 1):
			b = polygon_points[i + 1]
		polygon.append(Vector3(a.x, 0.0, a.y))
		polygon.append(Vector3(b.x, 0.0, b.y))
	
	add_lines(polygon, get_plugin().get_material("polygon", self), false)
