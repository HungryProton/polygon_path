tool
extends HBoxContainer

signal mode
signal options

func _on_ready():
	# Match the gizmo properties with the gui state
	var show_polygon = get_node("ShowPolygon")
	var show_grid = get_node("ShowGrid")
	_on_show_polygon(show_polygon.pressed)
	_on_show_grid(show_grid.pressed)

func _on_select():
	emit_signal("mode", "select")

func _on_add():
	emit_signal("mode", "add")

func _on_remove():
	emit_signal("mode", "remove")

func _on_show_polygon(value):
	emit_signal("options", "show_polygon", value)

func _on_show_grid(value):
	emit_signal("options", "show_grid", value)
