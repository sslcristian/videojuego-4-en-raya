extends CanvasLayer

signal answered(correct)

@onready var panel = $Panel
@onready var question_label = $Panel/QuestionLabel
@onready var feedback_label = $Panel/FeedbackLabel

@onready var button_1 = $Panel/Button1
@onready var button_2 = $Panel/Button2
@onready var button_3 = $Panel/Button3

var current_question = {}
var answered_already = false

# respuesta correcta REAL
var correct_answer_text = ""

# opciones mezcladas
var shuffled_options = []

func _ready():

	randomize()

	visible = false

	button_1.pressed.connect(func(): check_answer(button_1.text))
	button_2.pressed.connect(func(): check_answer(button_2.text))
	button_3.pressed.connect(func(): check_answer(button_3.text))


func show_question(question_data):

	visible = true

	answered_already = false

	current_question = question_data

	question_label.text = question_data.question

	feedback_label.text = ""

	# -----------------------------
	# COPIAR OPCIONES
	# -----------------------------
	shuffled_options = question_data.options.duplicate()

	# -----------------------------
	# MEZCLAR OPCIONES
	# -----------------------------
	shuffled_options.shuffle()

	# -----------------------------
	# GUARDAR RESPUESTA CORRECTA
	# -----------------------------
	correct_answer_text = question_data.options[
		question_data.answer
	]

	# -----------------------------
	# ASIGNAR TEXTO A BOTONES
	# -----------------------------
	button_1.text = shuffled_options[0]
	button_2.text = shuffled_options[1]
	button_3.text = shuffled_options[2]

	# -----------------------------
	# ACTIVAR BOTONES
	# -----------------------------
	button_1.disabled = false
	button_2.disabled = false
	button_3.disabled = false

	# -----------------------------
	# EFECTO VISUAL
	# -----------------------------
	panel.scale = Vector2(0.8, 0.8)

	var tween = create_tween()

	tween.tween_property(
		panel,
		"scale",
		Vector2(1,1),
		0.15
	)


func check_answer(selected_text):

	if answered_already:
		return

	answered_already = true

	button_1.disabled = true
	button_2.disabled = true
	button_3.disabled = true

	# -----------------------------
	# VALIDAR RESPUESTA
	# -----------------------------
	var correct = selected_text == correct_answer_text

	if correct:

		feedback_label.add_theme_color_override(
			"font_color",
			Color.GREEN
		)

		feedback_label.text = "✅ Correcto"

		await get_tree().create_timer(1.0).timeout

		visible = false

		answered.emit(true)

	else:

		feedback_label.add_theme_color_override(
			"font_color",
			Color.RED
		)

		# SOLO MOSTRAR PISTA
		feedback_label.text = "❌ " + current_question.hint

		await get_tree().create_timer(2.5).timeout

		visible = false

		answered.emit(false)
func hide_question():

	if not visible:
		return

	answered_already = true

	button_1.disabled = true
	button_2.disabled = true
	button_3.disabled = true

	visible = false

	answered.emit(false)
