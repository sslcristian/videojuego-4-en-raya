extends Node

const CELL_SIZE = 80
const ROWS = 6
const COLS = 7 

@export var piece_scene: PackedScene

# --- REFERENCIAS CORREGIDAS ---
@onready var pieces_view = $"../PiecesView"
@onready var board_view = $"../BoardView"
@onready var ui_layer = $"../UI"
# Usamos get_node_or_null para que el juego no se cierre si olvidas crear un nodo
@onready var winner_label = $"../UI/WinnerLabel"
@onready var restart_button = $"../UI/RestartButton"

var model = BoardModel.new()
var game_over = false

func _ready():
	model.create_board()
	
	# Configuración inicial: ocultamos la UI al empezar
	if winner_label: 
		winner_label.visible = false
	if restart_button: 
		restart_button.visible = false
		# Conectamos el click del botón a la función de reiniciar
		if not restart_button.pressed.is_connected(_on_restart_button_pressed):
			restart_button.pressed.connect(_on_restart_button_pressed)

func _input(event):
	if game_over:
		return

	if event is InputEventMouseButton and event.pressed:
		var local_pos = board_view.get_local_mouse_position()
		var column = int(local_pos.x / CELL_SIZE)

		if column < 0 or column >= COLS:
			return

		var result = model.place_piece(column)

		if result != null:
			spawn_piece_animated(result)
			
			var winner = model.check_victory(result.row, result.col)
			if winner != 0:
				# Esperamos un momento a que termine la animación antes de mostrar victoria
				get_tree().create_timer(0.6).timeout.connect(func(): show_victory(winner))

func spawn_piece_animated(data):
	var piece = piece_scene.instantiate()
	pieces_view.add_child(piece)
	piece.set_player(data.player)

	# --- AJUSTE VISUAL PARA TU TABLERO ---
	var board_origin = board_view.global_position
	
	# Estos márgenes centran la ficha en los huecos de tu imagen
	var margin_x = 60 
	var margin_y = 45

	var final_x = (data.col * CELL_SIZE) + margin_x
	var final_y = (ROWS - 1 - data.row) * CELL_SIZE + margin_y
	
	var pos_final = board_origin + Vector2(final_x, final_y)
	var pos_inicio = board_origin + Vector2(final_x, -200) # Empieza más arriba

	# --- ANIMACIÓN TWEEN ---
	piece.global_position = pos_inicio
	piece.scale = Vector2(0.7, 1.4) # Efecto de estiramiento al caer
	
	var tween = get_tree().create_tween()
	
	# Caída rápida
	tween.tween_property(piece, "global_position", pos_final, 0.4)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	# Impacto: se aplasta un poco (1.2 horizontal) y vuelve al tamaño normal (1.0)
	tween.parallel().tween_property(piece, "scale", Vector2(1.2, 0.8), 0.1).set_delay(0.4)
	tween.tween_property(piece, "scale", Vector2(1.0, 1.0), 0.1)

func show_victory(winner):
	game_over = true
	if winner_label:
		winner_label.text = "FELICIDADES\nGANADOR: JUGADOR " + str(winner)
		winner_label.visible = true
	if restart_button:
		restart_button.visible = true

func _on_restart_button_pressed():
	# Recarga la escena para volver a jugar
	get_tree().reload_current_scene()
