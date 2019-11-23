static func intersect_with(path, camera, screen_point):
	var from = camera.project_ray_origin(screen_point)
	var dir = camera.project_ray_normal(screen_point)
	var plane = _get_path_plane(path)
	return plane.intersects_ray(from, dir)

static func _get_path_plane(path):
	var t = path.get_global_transform()
	var a = t.basis.x
	var b = t.basis.z
	var c = a + b
	var o = t.origin
	return Plane(a + o, b + o, c + o)