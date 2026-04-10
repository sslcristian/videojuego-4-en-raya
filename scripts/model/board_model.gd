class_name BoardModel

const ROWS = 6
const COLS = 7

var board = []
var current_player = 1

func create_board():
	board.clear()

	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			row.append(0)
		board.append(row)

func place_piece(column):

	if column < 0 or column >= COLS:
		return null

	var player_played = current_player

	for row in range(ROWS-1, -1, -1):

		if board[row][column] == 0:

			board[row][column] = player_played

			var result = {
				"row": row,
				"col": column,
				"player": player_played
			}

			change_turn()
			return result

	return null

func change_turn():
	if current_player == 1:
		current_player = 2
	else:
		current_player = 1

func check_victory(row,col):

	var player = board[row][col]

	if check_direction(row,col,1,0,player):
		return player

	if check_direction(row,col,0,1,player):
		return player

	if check_direction(row,col,1,1,player):
		return player

	if check_direction(row,col,1,-1,player):
		return player

	return 0

func check_direction(row,col,dx,dy,player):

	var count = 1

	count += count_pieces(row,col,dx,dy,player)
	count += count_pieces(row,col,-dx,-dy,player)

	return count >= 4

func count_pieces(row,col,dx,dy,player):

	var r = row + dy
	var c = col + dx

	var count = 0

	while r >= 0 and r < ROWS and c >= 0 and c < COLS:

		if board[r][c] != player:
			break

		count += 1

		r += dy
		c += dx

	return count
