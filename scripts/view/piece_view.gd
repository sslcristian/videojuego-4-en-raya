extends Node2D

var player = 0
var is_selected = false

@onready var sprite = $Sprite2D


func set_player(p):
	player = p
	update_color()


func update_color():
	if player == 1:
		sprite.modulate = Color(1, 0.2, 0.2)
	elif player == 2:
		sprite.modulate = Color(0.2, 0.4, 1)


# 🔆 SELECCIONAR
func highlight():
	is_selected = true

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3,1.3), 0.15)

	sprite.modulate = Color(1.5,1.5,0) # glow amarillo


# 🔙 DESELECCIONAR
func unhighlight():
	is_selected = false

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.15)

	update_color()


# ✨ HOVER (opcional)
func hover():
	if not is_selected:
		scale = Vector2(1.1,1.1)

func unhover():
	if not is_selected:
		scale = Vector2(1,1)
