class_name QuestionModel

var questions = [

	# =========================
	# ARRAYS / MATRICES
	# =========================

	{
		"question":"¿Qué estructura usa índices numéricos?",
		"options":["Array","Árbol","Grafo"],
		"answer":0,
		"hint":"Los arrays permiten acceder usando posiciones como [0], [1], [2]."
	},

	{
		"question":"¿Cómo se accede a una posición en una matriz?",
		"options":["fila,columna","inicio,fin","padre,hijo"],
		"answer":0,
		"hint":"Las matrices usan coordenadas tipo tablero."
	},

	{
		"question":"¿Qué representa board[row][col] ?",
		"options":["Una celda","Una función","Un nodo"],
		"answer":0,
		"hint":"row y col representan coordenadas del tablero."
	},

	{
		"question":"¿Qué estructura es board?",
		"options":["Matriz","Pila","Cola"],
		"answer":0,
		"hint":"Tiene filas y columnas."
	},

	# =========================
	# PILAS
	# =========================

	{
		"question":"¿Qué estructura funciona LIFO?",
		"options":["Pila","Cola","Array"],
		"answer":0,
		"hint":"LIFO significa Last In First Out."
	},

	{
		"question":"En una pila, ¿qué elemento sale primero?",
		"options":["El último","El primero","El del medio"],
		"answer":0,
		"hint":"Piensa en una pila de platos."
	},

	{
		"question":"¿Qué operación agrega elementos a una pila?",
		"options":["Push","Pop","Shift"],
		"answer":0,
		"hint":"Push agrega elementos."
	},

	{
		"question":"¿Qué operación elimina elementos en una pila?",
		"options":["Pop","Push","Insert"],
		"answer":0,
		"hint":"Pop remueve el elemento superior."
	},

	# =========================
	# COLAS
	# =========================

	{
		"question":"¿Qué estructura usa FIFO?",
		"options":["Cola","Pila","Árbol"],
		"answer":0,
		"hint":"FIFO significa First In First Out."
	},

	{
		"question":"¿Quién sale primero en una cola?",
		"options":["El primero en entrar","El último","El más grande"],
		"answer":0,
		"hint":"Como una fila de personas."
	},

	{
		"question":"¿Qué operación agrega a una cola?",
		"options":["Enqueue","Pop","Peek"],
		"answer":0,
		"hint":"Enqueue significa insertar al final."
	},

	{
		"question":"¿Qué operación remueve de una cola?",
		"options":["Dequeue","Push","Append"],
		"answer":0,
		"hint":"Dequeue elimina el primero."
	},

	# =========================
	# ÁRBOLES
	# =========================

	{
		"question":"¿Qué estructura tiene nodos padre e hijos?",
		"options":["Árbol","Array","Cola"],
		"answer":0,
		"hint":"Se parece a un árbol invertido."
	},

	{
		"question":"¿Cómo se llama el nodo principal de un árbol?",
		"options":["Raíz","Hoja","Centro"],
		"answer":0,
		"hint":"Es el nodo inicial."
	},

	{
		"question":"¿Qué es una hoja en un árbol?",
		"options":["Nodo sin hijos","Nodo principal","Nodo vacío"],
		"answer":0,
		"hint":"Está al final del árbol."
	},

	# =========================
	# GRAFOS
	# =========================

	{
		"question":"¿Qué estructura conecta nodos mediante enlaces?",
		"options":["Grafo","Array","Pila"],
		"answer":0,
		"hint":"Se usa mucho en mapas y redes."
	},

	{
		"question":"¿Cómo se llaman las conexiones de un grafo?",
		"options":["Aristas","Filas","Bloques"],
		"answer":0,
		"hint":"Conectan vértices."
	},

	{
		"question":"¿Qué representan los nodos en un grafo?",
		"options":["Vértices","Matrices","Indices"],
		"answer":0,
		"hint":"Son los puntos conectados."
	},

	# =========================
	# ALGORITMOS
	# =========================

	{
		"question":"¿Qué hace un algoritmo?",
		"options":["Resuelve pasos","Guarda imágenes","Dibuja gráficos"],
		"answer":0,
		"hint":"Es una secuencia ordenada."
	},

	{
		"question":"¿Qué ciclo repite instrucciones?",
		"options":["for","break","return"],
		"answer":0,
		"hint":"Se usa para iterar."
	},

	{
		"question":"¿Qué palabra detiene un ciclo?",
		"options":["break","continue","for"],
		"answer":0,
		"hint":"Rompe el bucle."
	},

	{
		"question":"¿Qué hace continue en un loop?",
		"options":["Salta iteración","Detiene todo","Duplica datos"],
		"answer":0,
		"hint":"Continúa con la siguiente vuelta."
	}

]

func get_random_question():
	return questions.pick_random()
