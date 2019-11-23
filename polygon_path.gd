# --
# PolygonPath
# --
# Alternative to the built in Path node with the following features:
# + New gizmo for easier handling
# + Constrained to a 3D plane
# + New keyboard shortcuts to enable / disable handles mirrors, length and snap
# + Method to check if a projected point is inside the curve
# + Working solution to know if the curve was updated or not
# --

tool

extends Spatial

class_name PolygonPath

## --
## Signals
## --

signal curve_updated

## --
## Exported variables
## --

export var curve : Curve3D
export(float) var polygon_resolution : float = 1 setget _polygon_resolution_set
export(bool) var closed_loop : bool = false setget _closed_loop_set

## --
## Public variables
## --

var polygon : PolygonPathFinder
var polygon_points : PoolVector2Array
var size : Vector3
var center : Vector3

## --
## Internal variables
## --

## --
## Public methods
## --

func ensure_curve_is_valid() -> void:
	if not curve:
		curve = Curve3D.new()

func is_point_inside(point : Vector3):
	if not polygon:
		_update_from_curve()
	return polygon.is_point_inside(_get_projected_coords(point))

func add_point(position):
	ensure_curve_is_valid()
	curve.add_point(position)
	var current_index = curve.get_point_count() - 1
	var previous_index = current_index - 1
	if previous_index < 0:
		curve.set_point_in(current_index, Vector3(-1.0, 0.0, 0.0))
		curve.set_point_out(current_index, Vector3(1.0, 0.0, 0.0))
		return

	var dir = position - curve.get_point_position(previous_index)
	var dir_out = dir.normalized()
	var dir_in = -dir.normalized()

	curve.set_point_in(current_index, dir_in)
	curve.set_point_out(current_index, dir_out)

	_update_from_curve()

func remove_point(index):
	ensure_curve_is_valid()
	if index > curve.get_point_count() - 1:
		return
	curve.remove_point(index)
	_update_closed_loop("remove_point", index, null)
	_update_from_curve()

func set_point_position(index, pos):
	curve.set_point_position(index, pos)
	_update_closed_loop("set_point_position", index, pos)
	_update_from_curve()

func set_point_in(index, pos):
	curve.set_point_in(index, pos)
	_update_closed_loop("set_point_in", index, pos)
	_update_from_curve()

func set_point_out(index, pos):
	curve.set_point_out(index, pos)
	_update_closed_loop("set_point_out", index, pos)
	_update_from_curve()

func get_closest_to(pos):
	var closest = -1
	var dist_squared = -1

	for i in range(0, curve.get_point_count()):
		var point_pos = curve.get_point_position(i)
		var point_dist = point_pos.distance_squared_to(pos)

		if (closest == -1) or (dist_squared > point_dist):
			closest = i
			dist_squared = point_dist

	var threshold = 16 # Ignore if the closest point is farther than this
	if dist_squared >= threshold:
		return -1

	return closest

func remove_closest_to(pos):
	# Ignore if there's no point in the curve
	ensure_curve_is_valid()
	if curve.get_point_count() == 0:
		return
	var closest = get_closest_to(pos)
	remove_point(closest)

func to_path():
	var path = Path.new()
	path.curve = curve
	return path

## --
## Internal methods
## --

func _ready():
	_update_from_curve()

func _get_projected_coords(coords : Vector3):
	return Vector2(coords.x, coords.z)

func _polygon_resolution_set(value):
	if (value < 0.09):
		# Ignore values too small or it will generate too much geometry
		# and freeze the editor for several seconds at least
		return
	polygon_resolution = value
	if curve:
		curve.set_bake_interval(clamp(value, 0.09, 0.2))
		_update_from_curve()

func _closed_loop_set(value):
	closed_loop = value
	var start = curve.get_point_position(0)
	var end = curve.get_point_position(curve.get_point_count() - 1)
	var dist = (start - end).length_squared()

	if closed_loop and dist > 4:
		curve.add_point(start)
		var index = curve.get_point_count() - 1
		curve.set_point_position(index, start)
		curve.set_point_in(index, curve.get_point_in(0))
		curve.set_point_out(index, curve.get_point_out(0))
	elif not closed_loop and dist < 1.5:
		curve.remove_point(curve.get_point_count() - 1)

	_update_from_curve()

# Called by set_point_[in | position | out] and remove_point to mirror the
# changes to the other end of the loop if the index matches the first or
# last point of the curve
func _update_closed_loop(f, index, pos):
	if not closed_loop:
		return

	var last_index = curve.get_point_count() - 1
	if f == "remove_point":
		if index == last_index:
			return # Ignore it or it will be handled twice
		if index == 0:
			curve.remove_point(0)
			last_index = curve.get_point_count() - 1
			curve.set_point_position(last_index, curve.get_point_position(0))
			curve.set_point_in(last_index, curve.get_point_in(0))
			curve.set_point_out(last_index, curve.get_point_out(0))
	else:
		if index == last_index:
			curve.call(f, 0, pos)
		elif index == 0:
			curve.call(f, last_index, pos)

# Travel the whole path to update the polygon and bounds
func _update_from_curve():
	var _min = null
	var _max = null
	var connections = PoolIntArray()
	polygon_points = PoolVector2Array()

	if not curve:
		curve = Curve3D.new()

	var length = curve.get_baked_length()
	var steps = round(length / polygon_resolution)

	if steps == 0:
		return

	for i in range(steps):
		# Get a point on the curve
		var coords_3d = curve.interpolate_baked((i/(steps-2)) * length)
		var coords = _get_projected_coords(coords_3d)

		# Store polygon data
		polygon_points.append(coords)
		connections.append(i)
		if(i == steps - 1):
			connections.append(0)
		else:
			connections.append(i + 1)

		# Check for bounds
		if i == 0:
			_min = coords
			_max = coords
		else:
			if coords.x > _max.x:
				_max.x = coords.x
			if coords.x < _min.x:
				_min.x = coords.x
			if coords.y > _max.y:
				_max.y = coords.y
			if coords.y < _min.y:
				_min.y = coords.y

	if not polygon:
		polygon = PolygonPathFinder.new()
	polygon.setup(polygon_points, connections)
	size = Vector3(_max.x - _min.x, 0.0, _max.y - _min.y)
	center = Vector3((_min.x + _max.x) / 2, 0.0, (_min.y + _max.y) / 2)

	_on_curve_update()
	emit_signal("curve_updated")

# Curve update post hook. Children may inherit this function or listen to the
# curve_updated signal instead.
func _on_curve_update():
	pass
