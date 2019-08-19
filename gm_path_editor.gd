tool
extends EditorPlugin

signal mode
signal options

var _gm_path_type = preload("res://addons/gm_path/gm_path.gd")
var _path_gizmo = load("res://addons/gm_path/gm_path_gizmo_plugin.gd").new()
var _path_controls = preload("res://addons/gm_path/gui/gm_path_controls.tscn").instance()
var _edited_node = null
var _editor_selection : EditorSelection = null
var _mode = "select"

var common = load("res://addons/gm_path/common.gd")

# --
# EditorPlugin overrides
# --

func get_name(): 
	return "GM Path"

func _enter_tree():
	add_custom_type(
		"GM_Path", 
		"Spatial",
		load("res://addons/gm_path/gm_path.gd"),
		load("res://addons/gm_path/icons/path.svg")
	)
	_register_gizmos()
	_register_signals()

func _exit_tree():
	remove_custom_type("GM_Path")
	_deregister_gizmos()
	_deregister_signals()
	
func handles(node):
	return node is _gm_path_type

func edit(node):
	_show_control_panel()
	_edited_node = node

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
	if len(selected) == 0 or not selected[0] is GM_Path:
		_edited_node = null
		if _path_controls.get_parent():
			_hide_control_panel()

func _on_mode_change(mode):
	_mode = mode

func _on_option_change(option, value):
	match option:
		"show_polygon":
			_path_gizmo.show_polygon(value)
		"close_curve":
			_edited_node.set_closed_curve(value)

func forward_spatial_gui_input(camera, event):
	var captured_event = false
	
	if not _edited_node:
		return false

	if _mode == "select":
		return false

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var ray_hit_pos = common.intersect_with(_edited_node, camera, event.position)
			if ray_hit_pos:
				captured_event = true
				
				if _mode == "add" and not event.pressed:
					_edited_node.add_point(ray_hit_pos)
					_path_gizmo.force_redraw()
				if _mode == "remove" and not event.pressed:
					_edited_node.remove_closest_to(ray_hit_pos)
					_path_gizmo.force_redraw()
				#if _mode == "select" and not event.pressed:
				#	_path_gizmo.force_redraw()
	return captured_event

func _show_control_panel():
	if not _path_controls.get_parent():
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _path_controls)

func _hide_control_panel():
	if _path_controls.get_parent():
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _path_controls)