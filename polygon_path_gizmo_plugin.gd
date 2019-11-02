extends EditorSpatialGizmoPlugin

var gizmo = preload("res://addons/polygon_path/polygon_path_gizmo.gd")
var current_gizmo

func show_polygon(value):
	if current_gizmo:
		current_gizmo.show_polygon(value)

func show_grid(value):
	if current_gizmo:
		current_gizmo.show_grid(value)

func force_redraw():
	if current_gizmo:
		current_gizmo.redraw()

func consume_drag_info():
	if current_gizmo:
		return current_gizmo.consume_drag_info()
	else:
		return null

func _init():
	create_material("polygon", Color(1, 0, 0), false, true)
	create_material("path", Color(0, 0, 1), false, true)
	create_material("handle_lines", Color(0.1, 0.1, 0.1))
	create_material("grid", Color(0.7, 0.7, 0))
	create_handle_material("handles")
	create_square_handle_material("square")

func create_gizmo(node):
	if node is PolygonPath:
		current_gizmo = gizmo.new()
		return current_gizmo
	else:
		return null

func create_square_handle_material(name, p_billboard=false):
	var handle_material = SpatialMaterial.new()
	var handle_icon = ImageTexture.new()
	handle_icon.load("res://addons/polygon_path/icons/handle.svg")
	
	handle_material.set_flag(SpatialMaterial.FLAG_UNSHADED, true)
	handle_material.set_flag(SpatialMaterial.FLAG_USE_POINT_SIZE, true)
	handle_material.set_point_size(handle_icon.get_width())
	handle_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, handle_icon)
	handle_material.set_albedo(Color(1, 1, 1))
	handle_material.set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
	handle_material.set_flag(SpatialMaterial.FLAG_ALBEDO_FROM_VERTEX_COLOR, true)
	handle_material.set_flag(SpatialMaterial.FLAG_SRGB_VERTEX_COLOR, true)
	#handle_material.set_on_top_of_alpha()
	if (p_billboard):
		handle_material.set_billboard_mode(SpatialMaterial.BILLBOARD_ENABLED)
		handle_material.set_on_top_of_alpha()
	add_material(name, handle_material)
