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

func _ready():

	visible = false

	button_1.pressed.connect(func(): check_answer(0))
	button_2.pressed.connect(func(): check_answer(1))
	button_3.pressed.connect(func(): check_answer(2))

func show_question(question_data):

	visible = true
	answered_already = false

	current_question = question_data

	question_label.text = question_data.question
	feedback_label.text = ""

	button_1.text = question_data.options[0]
	button_2.text = question_data.options[1]
	button_3.text = question_data.options[2]

	button_1.disabled = false
	button_2.disabled = false
	button_3.disabled = false

func check_answer(index):

	if answered_already:
		return

	answered_already = true

	button_1.disabled = true
	button_2.disabled = true
	button_3.disabled = true

	var correct = index == current_question.answer

	if correct:

		feedback_label.text = "✅ Correcto"

		await get_tree().create_timer(1.0).timeout

		visible = false

		answered.emit(true)

	else:

		feedback_label.text = "❌ " + current_question.hint

		await get_tree().create_timer(2.5).timeout

		visible = false

		answered.emit(false)
