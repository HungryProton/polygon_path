tool
extends EditorPlugin

signal mode
signal options

var _path_gizmo = load("res://addons/polygon_path/polygon_path_gizmo_plugin.gd").new()
var _path_controls = preload("res://addons/polygon_path/gui/polygon_path_controls.tscn").instance()
var _edited_node = null
var _editor_selection : EditorSelection = null
var _mode = "select"

var common = load("res://addons/polygon_path/common.gd")

# --
# EditorPlugin overrides
# --

func get_name(): 
	return "PolygonPath"

func _enter_tree():
	add_custom_type(
		"PolygonPath", 
		"Spatial",
		load("res://addons/polygon_path/polygon_path.gd"),
		load("res://addons/polygon_path/icons/path.svg")
	)
	_register_gizmos()
	_register_signals()

func _exit_tree():
	remove_custom_type("PolygonPath")
	_deregister_gizmos()
	_deregister_signals()
	
func handles(node):
	return node is PolygonPath

func edit(node):
	_show_control_panel()
	_edited_node = node as PolygonPath

# --
# Internal methods
# --

func _register_gizmos():
	add_spatial_gizmo_plugin(_path_gizmo)
	_path_controls.connect("mode", self, "_on_mode_change")
	_path_controls.connect("options", self, "_on_option_change")

func _deregister_gizmos():
	remove_spatial_gizmo_plugin(_path_gizmo)
	_hide_control_panel()
	disconnect("mode", self, "_on_mode_change")
	disconnect("options", self, "_on_option_change")
	
func _register_signals():
	_editor_selection = get_editor_interface().get_selection()
	_editor_selection.connect("selection_changed", self, "_on_selection_change")

func _deregister_signals():
	_editor_selection.disconnect("selection_changed", self, "_on_selection_change")

func _on_selection_change():
	_editor_selection = get_editor_interface().get_selection()
	var selected = _editor_selection.get_selected_nodes()
	if len(selected) == 0 or not selected[0] is PolygonPath:
		_edited_node = null
		if _path_controls.get_parent():
			_hide_control_panel()

func _on_mode_change(mode):
	print("Selected mode : ", mode)
	_mode = mode

func _on_option_change(option, value):
	match option:
		"show_polygon":
			_path_gizmo.show_polygon(value)
		"close_curve":
			_edited_node.set_closed_curve(value)
		"show_grid":
			_path_gizmo.show_grid(value)

func forward_spatial_gui_input(camera, event):
	var captured_event = false

	if not _edited_node:
		return false

	#if _mode == "select":
	#	return false

	if (event is InputEventMouseButton) and (event.button_index == BUTTON_LEFT):
		var ray_hit_pos = common.intersect_with(_edited_node, camera, event.position)
		if not ray_hit_pos:
			return false
		
		captured_event = true
		var pos = _edited_node.to_local(ray_hit_pos)
		var undo = get_undo_redo()
		if _mode == "add" and not event.pressed:
			var next_index = _edited_node.curve.get_point_count()
			undo.create_action("Add point to PolygonPath")
			undo.add_undo_method(self, "_remove_closest_to", _edited_node, pos)
			undo.add_do_method(self, "_add_point", _edited_node, pos)
			undo.commit_action()
		if _mode == "remove" and not event.pressed:
			var index = _edited_node.get_closest_to(pos)
			if index == -1: # No point will be removed
				return captured_event
			var previous_pos = _edited_node.curve.get_point_position(index)
			var vec_in = _edited_node.curve.get_point_in(index)
			var vec_out = _edited_node.curve.get_point_out(index)
			undo.create_action("Remove point from PolygonPath")
			undo.add_undo_method(self, "_add_point_at", _edited_node, index, previous_pos, vec_in, vec_out)
			undo.add_do_method(self, "_remove_closest_to", _edited_node, pos)
			undo.commit_action()
		if _mode == "select":
			captured_event = false
			if event.pressed:
				return captured_event
			var d = _path_gizmo.consume_drag_info()
			undo.create_action("Move point from PolygonPath")
			undo.add_undo_method(self, "_set_point", _edited_node, d.index, d.old_pos, d.old_in, d.old_out)
			undo.add_do_method(self, "_set_point", _edited_node, d.index, d.new_pos, d.new_in, d.new_out)
			undo.commit_action()
			
	return captured_event

func _set_point(node, index, pos, vec_in, vec_out):
	node.curve.set_point_position(index, pos)
	node.curve.set_point_in(index, vec_in)
	node.curve.set_point_out(index, vec_out)
	node._update_from_curve()
	_path_gizmo.force_redraw()

func _add_point(node, pos):
	node.add_point(pos)
	_path_gizmo.force_redraw()

func _add_point_at(node, index, pos, vec_in, vec_out):
	node.curve.add_point(pos, vec_in, vec_out, index)
	node._update_from_curve()
	_path_gizmo.force_redraw()

func _remove_point(node, index):
	node.remove_point(index)
	_path_gizmo.force_redraw()

func _remove_closest_to(node, pos):
	node.remove_closest_to(pos)
	_path_gizmo.force_redraw()

func _show_control_panel():
	if not _path_controls.get_parent():
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _path_controls)

func _hide_control_panel():
	if _path_controls.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _path_controls)