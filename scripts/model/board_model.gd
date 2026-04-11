class_name BoardModel

const ROWS = 6
const COLS = 7

var board = []

# gravedad: 1 = abajo, -1 = arriba
var gravity = 1


# -------------------------------
# CREAR TABLERO
# -------------------------------
func create_board():
	board.clear()

	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			row.append(0)
		board.append(row)


# -------------------------------
# COLOCAR FICHA
# -------------------------------
func place_piece(column, player):

	if column < 0 or column >= COLS:
		return null

	if gravity == 1:
		for row in range(ROWS-1, -1, -1):
			if board[row][column] == 0:
				board[row][column] = player
				return {"row":row,"col":column,"player":player}
	else:
		for row in range(0, ROWS):
			if board[row][column] == 0:
				board[row][column] = player
				return {"row":row,"col":column,"player":player}

	return null


# -------------------------------
# VICTORIA
# -------------------------------
func check_victory(row,col):

	var player = get_player_from_cell(board[row][col])

	if player == 0:
		return 0

	if check_direction(row,col,1,0,player): return player
	if check_direction(row,col,0,1,player): return player
	if check_direction(row,col,1,1,player): return player
	if check_direction(row,col,1,-1,player): return player

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
		if get_player_from_cell(board[r][c]) != player:
			break
		count += 1
		r += dy
		c += dx

	return count


func get_player_from_cell(value):
	if value == 1 or value == 3:
		return 1
	if value == 2 or value == 4:
		return 2
	return 0


# -------------------------------
# 🔄 GRAVEDAD
# -------------------------------
func apply_gravity():

	for c in range(COLS):

		var pieces = []

		for r in range(ROWS):
			if board[r][c] != 0:
				pieces.append(board[r][c])

		# limpiar columna
		for r in range(ROWS):
			board[r][c] = 0

		if gravity == 1:
			var index = ROWS - 1
			for p in pieces:
				board[index][c] = p
				index -= 1
		else:
			var index = 0
			for p in pieces:
				board[index][c] = p
				index += 1


# -------------------------------
# 🔁 INVERTIR GRAVEDAD
# -------------------------------
func invert_gravity():
	gravity *= -1
	apply_gravity()


# -------------------------------
# 🔃 ROTAR TABLERO (90°)
# -------------------------------
func rotate_board():

	var new_board = []

	for c in range(COLS):
		var new_row = []
		for r in range(ROWS-1, -1, -1):
			new_row.append(board[r][c])
		new_board.append(new_row)

	board = []

	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			if r < new_board.size() and c < new_board[0].size():
				row.append(new_board[r][c])
			else:
				row.append(0)
		board.append(row)

	apply_gravity()


# -------------------------------
# ⬇️ DESPLAZAR COLUMNA
# -------------------------------
func shift_column(column):

	if column < 0 or column >= COLS:
		return

	if gravity == 1:
		for r in range(ROWS-1, 0, -1):
			board[r][column] = board[r-1][column]
		board[0][column] = 0
	else:
		for r in range(0, ROWS-1):
			board[r][column] = board[r+1][column]
		board[ROWS-1][column] = 0


# -------------------------------
# 🔁 REUBICAR FICHA (FIX PRO 🔥)
# -------------------------------
func get_top_piece(column, player):

	for r in range(ROWS):
		var val = board[r][column]

		if val != 0 and get_player_from_cell(val) == player:

			# SOLO verifica si es la ficha superior (NO la borra)
			if gravity == 1:
				if r == 0 or board[r-1][column] == 0:
					return {"row":r,"col":column,"value":val}
			else:
				if r == ROWS-1 or board[r+1][column] == 0:
					return {"row":r,"col":column,"value":val}

	return null


func move_piece(piece_data, new_column):

	if piece_data == null:
		return

	var old_row = piece_data["row"]
	var old_col = piece_data["col"]
	var val = piece_data["value"]

	# 🔴 borrar ficha original (AHORA SÍ, en el momento correcto)
	board[old_row][old_col] = 0

	if gravity == 1:
		for r in range(ROWS-1, -1, -1):
			if board[r][new_column] == 0:
				board[r][new_column] = val
				return
	else:
		for r in range(0, ROWS):
			if board[r][new_column] == 0:
				board[r][new_column] = val
				return


# -------------------------------
# 💣 EXPLOSIÓN
# -------------------------------
func explode(row,col):

	var dirs = [
		Vector2(1,0),
		Vector2(-1,0),
		Vector2(0,1),
		Vector2(0,-1)
	]

	board[row][col] = 0

	for d in dirs:
		var r = row + int(d.y)
		var c = col + int(d.x)

		if r >= 0 and r < ROWS and c >= 0 and c < COLS:
			board[r][c] = 0

	apply_gravity()
