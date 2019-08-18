extends EditorSpatialGizmoPlugin

var GM_Path = preload("res://addons/gm_path/gm_path.gd")
var gizmo = preload("res://addons/gm_path/gm_path_gizmo.gd")
var current_gizmo

var _mode = "select"
var _show_polygon = false

func show_polygon(value):
	current_gizmo.show_polygon(value)

func force_redraw():
	current_gizmo.redraw()

func _init():
	create_material("polygon", Color(1, 0, 0), false, true)
	create_material("path", Color(0, 0, 1), false, true)
	create_material("grid", Color(0.7, 0.7, 0))
	create_handle_material("handles")

func create_gizmo(node):
	if node is GM_Path:
		current_gizmo = gizmo.new()
		return current_gizmo
	else:
		return null