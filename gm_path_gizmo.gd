extends EditorSpatialGizmo

var common = load("res://addons/gm_path/common.gd")

var show_polygon : bool = false

func show_polygon(value):
	show_polygon = value
	redraw()

func set_handle(index, camera, point):
	var gm_path = get_spatial_node()
	var ray_hit_pos = common.intersect_with(gm_path, camera, point)
	
	if(ray_hit_pos):
		gm_path.set_point_position(index, ray_hit_pos)
		redraw()

func redraw():
	clear()
	var gm_path = get_spatial_node()
	_draw_grid(gm_path)
	_draw_path(gm_path.curve)
	_draw_handles(gm_path.curve)
	_draw_polygon(gm_path)

func _draw_grid(gm_path):
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

	for i in range(curve.get_point_count()):
		handles.push_back(curve.get_point_position(i))
	
	if len(handles) > 0:
		add_handles(handles, get_plugin().get_material("handles", self))

func _draw_polygon(gm_path):
	if not show_polygon:
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
