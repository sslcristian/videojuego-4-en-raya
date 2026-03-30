extends RefCounted
class_name BoardModel

var rows = 6
var cols = 7

var board = []

func _init():
	create_board()

func create_board():
	board.clear()
	for r in range(rows):
		board.append([])
		for c in range(cols):
			board[r].append(0)

func get_cell(r,c):
	return board[r][c]

func set_cell(r,c,value):
	board[r][c] = value


func drop_piece(column:int, player:int):

	for r in range(rows-1, -1, -1):

		if board[r][column] == 0:

			board[r][column] = player
			return r

	return -1



func check_victory(player:int):

	for r in range(rows):
		for c in range(cols):

			if board[r][c] != player:
				continue

			if check_direction(r,c,1,0,player):
				return true

			if check_direction(r,c,0,1,player):
				return true

			if check_direction(r,c,1,1,player):
				return true

			if check_direction(r,c,1,-1,player):
				return true

	return false


func check_direction(r,c,dr,dc,player):

	for i in range(4):

		var nr = r + dr*i
		var nc = c + dc*i

		if nr < 0 or nr >= rows or nc < 0 or nc >= cols:
			return false

		if board[nr][nc] != player:
			return false

	return true


func rotate_board():

	var new_board = []

	for c in range(cols):
		new_board.append([])

	for r in range(rows):
		for c in range(cols):
			new_board[c].insert(0, board[r][c])

	board = new_board

	var temp = rows
	rows = cols
	cols = temp

	apply_gravity()



func apply_gravity():

	for c in range(cols):

		var pieces = []

		for r in range(rows):

			if board[r][c] != 0:
				pieces.append(board[r][c])

		for r in range(rows):
			board[r][c] = 0

		var index = rows-1

		for p in pieces:

			board[index][c] = p
			index -= 1
