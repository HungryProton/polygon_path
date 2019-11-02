class_name PolygonPathDragInfo

var index : int = -1
var old_in : Vector3 = Vector3.ZERO
var old_out : Vector3 = Vector3.ZERO
var old_pos : Vector3 = Vector3.ZERO
var new_in : Vector3 = Vector3.ZERO
var new_out : Vector3 = Vector3.ZERO
var new_pos : Vector3 = Vector3.ZERO

func reset():
	index = -1
	old_in = Vector3.ZERO
	old_out = Vector3.ZERO
	old_pos = Vector3.ZERO
	new_in = Vector3.ZERO
	new_out = Vector3.ZERO
	new_pos = Vector3.ZERO

static func assign(a, b):
	a.index = b.index
	a.old_in = b.old_in
	a.old_out = b.old_out
	a.old_pos = b.old_pos
	a.new_in = b.new_in
	a.new_out = b.new_out
	a.new_pos = b.new_pos