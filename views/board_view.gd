extends Node2D
class_name BoardView

signal column_clicked(col)

@onready var grid = $GridContainer

var cells = []

func create_board(rows,cols):

	grid.columns = cols

	for r in range(rows):

		cells.append([])

		for c in range(cols):

			var cell = preload("res://scenes/cell.tscn").instantiate()

			grid.add_child(cell)

			cell.connect("clicked", Callable(self,"_on_cell_clicked").bind(c))

			cells[r].append(cell)


func _on_cell_clicked(col):

	emit_signal("column_clicked", col)



func update_board(board):

	for r in range(board.rows):
		for c in range(board.cols):

			var value = board.board[r][c]

			var cell = cells[r][c]

			if value == 1:
				cell.text = "R"
			elif value == 2:
				cell.text = "B"
			else:
				cell.text = ""
