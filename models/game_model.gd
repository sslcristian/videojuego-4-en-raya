extends RefCounted
class_name GameModel

var board : BoardModel

var players = []

var current_player = 1

var rotations_left = 2

func _init():

	board = BoardModel.new()

	players.append(PlayerModel.new(1))
	players.append(PlayerModel.new(2))



func change_turn():

	if current_player == 1:
		current_player = 2
	else:
		current_player = 1
