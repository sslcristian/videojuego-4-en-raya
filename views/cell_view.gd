extends Button
class_name CellView

signal clicked

func _pressed():
	emit_signal("clicked")
