extends Node

const CELL_SIZE = 80
const ROWS = 6
const COLS = 7 

@export var piece_scene: PackedScene

# --- REFERENCIAS ---
@onready var pieces_view = $"../PiecesView"
@onready var board_view = $"../BoardView"
@onready var ui_layer = $"../UI"
@onready var winner_label = $"../UI/WinnerLabel"
@onready var restart_button = $"../UI/RestartButton"
@onready var turn_label = $"../UI/TurnLabel"

var model = BoardModel.new()
var game_over = false
var can_place_piece = true
var current_player = 1

# NUEVA VARIABLE: Guarda quién fue el último perdedor (para la próxima partida)
var last_loser = 0  # 0 = sin juego previo, 1 o 2 = el que perdió

func _ready():
	# Si es la primera partida, empieza el jugador 1
	if last_loser == 0:
		current_player = 1
	else:
		# Si hay un perdedor guardado, empieza él
		current_player = last_loser
		print("🎯 Partida de revancha: Empieza el Jugador ", current_player, " (perdedor anterior)")
	
	model.create_board()
	
	# Configuración inicial de UI
	if winner_label: 
		winner_label.visible = false
	if restart_button: 
		restart_button.visible = false
		if not restart_button.pressed.is_connected(_on_restart_button_pressed):
			restart_button.pressed.connect(_on_restart_button_pressed)
	
	# Conectar los 7 botones de columna
	conectar_botones_columnas()
	
	update_turn_label()

func conectar_botones_columnas():
	var botones = []
	
	# Buscar todos los botones hijos de UI (excepto RestartButton)
	for child in ui_layer.get_children():
		if child is Button and child != restart_button:
			botones.append(child)
	
	# Ordenar por nombre para asegurar el orden correcto
	botones.sort_custom(func(a, b): 
		return a.name.naturalnocasecmp_to(b.name) < 0
	)
	
	# Conectar cada botón a su columna correspondiente
	for i in range(botones.size()):
		var boton = botones[i]
		var columna = i
		boton.pressed.connect(func(): _on_column_button_pressed(columna))
		print("✅ Botón ", boton.name, " conectado a columna ", columna)

func _on_column_button_pressed(column: int):
	# Validaciones
	if game_over:
		print("⛔ Juego terminado")
		return
	
	if not can_place_piece:
		print("⏳ Espera a que termine la animación")
		return
	
	if column < 0 or column >= COLS:
		print("❌ Columna inválida: ", column)
		return
	
	# Intentar colocar ficha en el modelo
	var result = model.place_piece(column)
	
	if result == null:
		print("📦 Columna ", column, " está llena")
		return
	
	# Bloquear nuevos movimientos durante la animación
	can_place_piece = false
	
	# Asignar jugador actual al resultado
	result.player = current_player
	
	# Mostrar la ficha con animación
	spawn_piece_animated(result)
	
	# Verificar si hay ganador
	var winner = model.check_victory(result.row, result.col)
	if winner != 0:
		await get_tree().create_timer(0.6).timeout
		show_victory(winner)
	else:
		switch_turn()
		await get_tree().create_timer(0.5).timeout
		can_place_piece = true

func switch_turn():
	current_player = 3 - current_player
	update_turn_label()
	print("🔄 Turno del Jugador ", current_player)

func update_turn_label():
	if turn_label:
		turn_label.text = "TURNO: JUGADOR " + str(current_player)
		if current_player == 1:
			turn_label.modulate = Color.RED
		else:
			turn_label.modulate = Color.YELLOW

func spawn_piece_animated(data):
	var piece = piece_scene.instantiate()
	pieces_view.add_child(piece)
	piece.set_player(data.player)
	
	# --- CÁLCULO DE POSICIONES ---
	var board_origin = board_view.global_position
	
	# Márgenes para centrar las fichas en los huecos
	var margin_x = 60 
	var margin_y = 45
	
	# Posición X según columna
	var final_x = (data.col * CELL_SIZE) + margin_x
	
	# Posición Y según fila
	var final_y = data.row * CELL_SIZE + margin_y
	
	var pos_final = board_origin + Vector2(final_x, final_y)
	var pos_inicio = board_origin + Vector2(final_x, -200)
	
	# Configuración inicial de la ficha
	piece.global_position = pos_inicio
	piece.scale = Vector2(1, 1)
	
	# --- ANIMACIÓN DE CAÍDA CON REBOTE ---
	var tween = get_tree().create_tween()
	tween.set_parallel(false)
	
	# 1. Caída rápida
	tween.tween_property(piece, "global_position:y", pos_final.y, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	# 2. Rebote hacia arriba
	tween.tween_property(piece, "global_position:y", pos_final.y - 15, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	# 3. Caída final suave
	tween.tween_property(piece, "global_position:y", pos_final.y, 0.08)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	print("🎯 Ficha colocada en columna ", data.col, ", fila ", data.row)

func show_victory(winner):
	game_over = true
	can_place_piece = false
	
	# NUEVO: Guardar quién perdió (el otro jugador)
	# Si ganó el jugador 1, el perdedor es el 2 y viceversa
	last_loser = 3 - winner  # Esto convierte 1→2 y 2→1
	print("📝 Guardado: El perdedor fue el Jugador ", last_loser, " (empezará la próxima partida)")
	
	if winner_label:
		winner_label.text = "FELICIDADES\nGANADOR: JUGADOR " + str(winner)
		winner_label.visible = true
	
	if restart_button:
		restart_button.visible = true
	
	print("🏆 ¡Jugador ", winner, " ha ganado!")

func _on_restart_button_pressed():
	print("🔄 Reiniciando juego...")
	print("🎮 Nueva partida - Empieza el Jugador ", last_loser, " (el que perdió anteriormente)")
	
	# En lugar de recargar toda la escena, reiniciamos manualmente
	reiniciar_juego()

func reiniciar_juego():
	# Limpiar todas las fichas del tablero visual
	for child in pieces_view.get_children():
		child.queue_free()
	
	# Reiniciar el modelo (tablero lógico)
	model.create_board()
	
	# Configurar quién empieza (el último perdedor)
	current_player = last_loser if last_loser != 0 else 1
	update_turn_label()
	
	# Resetear estados del juego
	game_over = false
	can_place_piece = true
	
	# Ocultar UI de victoria
	if winner_label:
		winner_label.visible = false
	if restart_button:
		restart_button.visible = false
	
	print("✅ Juego reiniciado. Empieza el Jugador ", current_player)
