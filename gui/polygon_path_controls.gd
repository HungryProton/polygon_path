tool
extends HBoxContainer

signal mode
signal options


func _on_select():
	emit_signal("mode", "select")

func _on_add():
	emit_signal("mode", "add")

func _on_remove():
	emit_signal("mode", "remove")

func _on_close_curve(value):
	emit_signal("options", "close_curve", value)

func _on_show_polygon(value):
	emit_signal("options", "show_polygon", value)

func _on_show_grid(value):
	emit_signal("options", "show_grid", value)
