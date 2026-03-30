extends Node

var model : GameModel

var view : BoardView


func _ready():

	model = GameModel.new()

	view = $BoardView

	view.create_board(model.board.rows, model.board.cols)

	view.connect("column_clicked", Callable(self,"play_turn"))



func play_turn(column):

	var row = model.board.drop_piece(column, model.current_player)

	if row == -1:
		return

	update_view()

	if model.board.check_victory(model.current_player):

		print("Jugador ",model.current_player," gana")
		return

	model.change_turn()



func update_view():

	view.update_board(model.board)
