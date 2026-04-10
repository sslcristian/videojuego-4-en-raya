extends Node2D

var player = 0

func set_player(p):
	player = p

	if player == 1:
		$Sprite2D.modulate = Color.RED

	if player == 2:
		$Sprite2D.modulate = Color.BLUE
