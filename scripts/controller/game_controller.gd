extends Node

const CELL_SIZE = 80
const ROWS = 6  # número de filas de tu tablero

@export var piece_scene: PackedScene

@onready var pieces_view = $"../PiecesView"
@onready var board_view = $"../BoardView"

var model = BoardModel.new()
var game_over = false


func _ready():
	model.create_board()


func _input(event):

	if game_over:
		return

	if event is InputEventMouseButton and event.pressed:

		var local_pos = board_view.to_local(event.position)
		var column = int(local_pos.x / CELL_SIZE)

		if column < 0 or column >= model.COLS:
			return

		var result = model.place_piece(column)

		if result != null:

			spawn_piece(result)

			var winner = model.check_victory(result.row, result.col)

			if winner != 0:
				print("Gana jugador ", winner)
				game_over = true


func spawn_piece(data):

	var piece = piece_scene.instantiate()
	pieces_view.add_child(piece)

	# 🔥 POSICIÓN BIEN CALCULADA
	var x = data.col * CELL_SIZE + CELL_SIZE / 2.0
	var y = (ROWS - 1 - data.row) * CELL_SIZE + CELL_SIZE / 2.0

	# 🔥 OFFSET PARA AJUSTAR AL TABLERO
	var offset = board_view.position + Vector2(25, 50)

	piece.position = offset + Vector2(x, y)

	piece.set_player(data.player)
