extends Node

const CELL_SIZE = 80
const ROWS = 6
const COLS = 7 

@export var piece_scene: PackedScene

@onready var pieces_view = $"../PiecesView"
@onready var board_view = $"../BoardView"
@onready var ui_layer = $"../UI"
@onready var winner_label = $"../UI/WinnerLabel"
@onready var restart_button = $"../UI/RestartButton"
@onready var turn_label = $"../UI/TurnLabel"
@onready var message_label = $"../UI/MessageLabel"
@onready var timer_label = $"../UI/TimerLabel"

# 🔊 SONIDOS
@onready var sfx_drop = $"../BoardView/Audio/DropSound"
@onready var sfx_explosion = $"../BoardView/Audio/ExplosionSound"
@onready var sfx_click = $"../BoardView/Audio/ClickSound"
@onready var sfx_timer = $"../BoardView/Audio/TimerSound"
@onready var sfx_victory = $"../BoardView/Audio/Victory"

# PODERES
@onready var btn_bloquear = $"../UI/BLOQUEAR"
@onready var btn_invertir = $"../UI/INVERTIR"
@onready var btn_explosiva = $"../UI/EXPLOSIVA"
@onready var btn_rotar = $"../UI/ROTAR"
@onready var btn_desplazar = $"../UI/DESPLAZAR"
@onready var btn_reubicar = $"../UI/REUBICAR"

# 🧠 QUIZ
@onready var quiz_manager = $"../QuizManager"

var question_model = QuestionModel.new()
var waiting_for_quiz = false

var column_buttons = []

var model = BoardModel.new()

var game_over = false
var can_place_piece = true
var current_player = 1

var selected_power = ""
var used_powers = {1:{},2:{}}

var blocked_column = -1
var block_turns = 0
var block_owner = 0

var gravity_temp_inverted = false
var selected_piece_pos = null

var last_loser = 0
var turn_counter = 0

var pieces_map = {}

# ⏱ TIMER
var turn_time = 30
var timer_running = false

# -------------------------------
func _ready():

	current_player = last_loser if last_loser != 0 else 1
	model.create_board()

	winner_label.visible = false
	restart_button.visible = false
	message_label.visible = false

	restart_button.pressed.connect(_on_restart_button_pressed)

	conectar_botones_columnas()

	btn_bloquear.pressed.connect(func(): select_power("bloquear"))
	btn_invertir.pressed.connect(func(): select_power("invertir"))
	btn_explosiva.pressed.connect(func(): select_power("explosiva"))
	btn_desplazar.pressed.connect(func(): select_power("desplazar"))
	btn_reubicar.pressed.connect(func(): select_power("reubicar"))
	btn_rotar.pressed.connect(func(): select_power("rotar"))

	update_turn_label()
	start_turn_timer()

# -------------------------------
func _process(delta):

	if not timer_running or game_over:
		return

	turn_time -= delta

	if turn_time <= 0:

		timer_label.text = "Tiempo: 0"
		timer_running = false

		show_message("Tiempo agotado!")
		end_turn()

	else:

		timer_label.text = "Tiempo: " + str(int(turn_time))

		# 🔊 sonido cuando quedan 5 segundos
		if int(turn_time) == 5 and not sfx_timer.playing:
			sfx_timer.play()

# -------------------------------
func start_turn_timer():

	turn_time = 30
	timer_running = true

# -------------------------------
func conectar_botones_columnas():

	for child in ui_layer.get_children():

		if child is Button and child != restart_button \
		and child != btn_bloquear and child != btn_invertir \
		and child != btn_explosiva and child != btn_rotar \
		and child != btn_desplazar and child != btn_reubicar:

			column_buttons.append(child)

	column_buttons.sort_custom(
		func(a,b):
			return a.name.naturalnocasecmp_to(b.name) < 0
	)

	for i in range(column_buttons.size()):

		var col = i

		column_buttons[i].pressed.connect(
			func():
				_on_column_button_pressed(col)
		)

# -------------------------------
func update_block_visual():

	for btn in column_buttons:
		btn.modulate = Color(1,1,1)

	if block_turns > 0 and blocked_column != -1:

		if current_player != block_owner:
			column_buttons[blocked_column].modulate = Color(1,0.3,0.3)

# -------------------------------
func show_message(text):

	message_label.text = text
	message_label.visible = true

	await get_tree().create_timer(1.2).timeout

	message_label.visible = false

# -------------------------------
# 🧠 NUEVO SISTEMA DE QUIZ
# -------------------------------
func select_power(power):

	sfx_click.play(2.30)

	if waiting_for_quiz:
		return

	if used_powers[current_player].has(power):

		show_message("Ya usaste este poder")
		return

	waiting_for_quiz = true
	can_place_piece = false

	var q = question_model.get_random_question()

	quiz_manager.show_question(q)

	var correct = await quiz_manager.answered

	waiting_for_quiz = false
	can_place_piece = true

	if correct:

		selected_power = power

		show_message("✅ Poder desbloqueado: " + power)

	else:

		selected_power = ""

		show_message("❌ Debes aprender para usar este poder")

# -------------------------------
func _on_column_button_pressed(column):

	if game_over or not can_place_piece:
		return

	if waiting_for_quiz:
		return

	if block_turns > 0 and column == blocked_column and current_player != block_owner:

		show_message("Columna bloqueada")
		return

	if selected_power != "":

		use_power(column)
		return

	var result = model.place_piece(column, current_player)

	if result == null:

		show_message("Columna llena")
		return

	spawn_piece_animated(result)

	await check_after_move(result)

# -------------------------------
func use_power(column = -1):

	sfx_click.play()

	match selected_power:

		"bloquear":

			blocked_column = column
			block_turns = 4
			block_owner = current_player

			update_block_visual()

		"invertir":

			model.invert_gravity()

			gravity_temp_inverted = true

			await redraw_board()

		"explosiva":

			var r = model.place_piece(column, current_player)

			if r == null:

				show_message("Columna llena")
				return

			r.explosive = true

			spawn_piece_animated(r)

			await check_after_move(r)

			used_powers[current_player][selected_power] = true
			selected_power = ""

			return

		"desplazar":

			model.shift_column(column)

			await redraw_board()

		"reubicar":

			if selected_piece_pos == null:

				var piece_data = model.get_top_piece(column, current_player)

				if piece_data == null:

					show_message("Selecciona ficha válida")
					return

				selected_piece_pos = piece_data

				var key = str(piece_data.row) + "_" + str(piece_data.col)

				if pieces_map.has(key):
					pieces_map[key].highlight()

				show_message("Elige destino")

				return

			else:

				var old_key = str(selected_piece_pos.row) + "_" + str(selected_piece_pos.col)

				if pieces_map.has(old_key):
					pieces_map[old_key].unhighlight()

				model.move_piece(selected_piece_pos, column)

				selected_piece_pos = null

				await redraw_board()

		"rotar":

			await animar_rotacion()

			model.rotate_board()

			await redraw_board()

	used_powers[current_player][selected_power] = true

	selected_power = ""

	end_turn()

# -------------------------------
func animar_rotacion():

	can_place_piece = false

	var tween = create_tween()

	tween.tween_property(
		board_view,
		"rotation_degrees",
		90,
		0.4
	)

	await tween.finished

	board_view.rotation_degrees = 0

	can_place_piece = true

# -------------------------------
func check_after_move(result):

	await handle_explosiva(result)

	var winner = check_full_board()

	if winner != 0:

		show_victory(winner)

	else:

		end_turn()

# -------------------------------
func handle_explosiva(result):

	if not result.has("explosive"):
		return

	# 🔊 EXPLOSIÓN
	sfx_explosion.play(3.8)

	model.explode(result.row, result.col)

	await get_tree().create_timer(0.15).timeout

	await redraw_board()

# -------------------------------
func check_full_board():

	for r in range(ROWS):

		for c in range(COLS):

			if model.board[r][c] != 0:

				var w = model.check_victory(r,c)

				if w != 0:
					return w

	return 0

# -------------------------------
func end_turn():

	timer_running = false

	if gravity_temp_inverted:

		model.invert_gravity()

		gravity_temp_inverted = false

		await redraw_board()

	if block_turns > 0:
		block_turns -= 1

	current_player = 3 - current_player

	update_turn_label()

	update_block_visual()

	# 🔢 CONTADOR DE TURNOS
	turn_counter += 1

	# 🔄 ROTACIÓN AUTOMÁTICA CADA 4 TURNOS
	if turn_counter >= 4:

		turn_counter = 0

		can_place_piece = false

		# animación
		await animar_rotacion()

		# rotar tablero
		model.rotate_board()

		# redibujar
		await redraw_board()

	await get_tree().create_timer(0.2).timeout

	can_place_piece = true

	start_turn_timer()

# -------------------------------
func redraw_board():

	can_place_piece = false

	for c in pieces_view.get_children():
		c.queue_free()

	await get_tree().process_frame
	await get_tree().process_frame

	pieces_map.clear()

	for r in range(ROWS):

		for c in range(COLS):

			var val = model.board[r][c]

			if val != 0:

				spawn_piece_animated({
					"row": r,
					"col": c,
					"player": val
				})

	can_place_piece = true

# -------------------------------
func update_turn_label():

	turn_label.text = "TURNO: JUGADOR " + str(current_player)

# -------------------------------
func spawn_piece_animated(data):

	var piece = piece_scene.instantiate()

	pieces_view.add_child(piece)

	piece.set_player(data.player)

	var key = str(data.row) + "_" + str(data.col)

	pieces_map[key] = piece

	var board_origin = board_view.global_position

	var margin_x = 60 
	var margin_y = 45

	var final_x = (data.col * CELL_SIZE) + margin_x
	var final_y = data.row * CELL_SIZE + margin_y

	var pos_final = board_origin + Vector2(final_x, final_y)
	var pos_inicio = board_origin + Vector2(final_x, -200)

	piece.global_position = pos_inicio

	var tween = create_tween()

	tween.tween_property(piece, "global_position:y", pos_final.y, 0.3)
	tween.tween_property(piece, "global_position:y", pos_final.y - 15, 0.1)
	tween.tween_property(piece, "global_position:y", pos_final.y, 0.08)

	# 🔊 sonido caída
	sfx_drop.play(1.93)

# -------------------------------
func show_victory(winner):

	game_over = true
	timer_running = false
	can_place_piece = false

	last_loser = 3 - winner

	winner_label.text = "GANADOR: JUGADOR " + str(winner)

	winner_label.visible = true

	sfx_victory.play()

	restart_button.visible = true

# -------------------------------
func _on_restart_button_pressed():

	reiniciar_juego()

# -------------------------------
func reiniciar_juego():

	for c in pieces_view.get_children():
		c.queue_free()

	await get_tree().process_frame

	model.create_board()

	current_player = last_loser if last_loser != 0 else 1

	game_over = false
	can_place_piece = true

	used_powers = {1:{},2:{}}

	selected_power = ""

	waiting_for_quiz = false

	blocked_column = -1
	block_turns = 0
	block_owner = 0

	turn_counter = 0

	update_block_visual()

	winner_label.visible = false
	restart_button.visible = false

	update_turn_label()

	start_turn_timer()
