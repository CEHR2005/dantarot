extends Camera2D

func _process(delta):


	# Проверка нажатия клавиш и определение направления
	if Input.is_action_pressed("ui_right"):
		offset.x += 1
	if Input.is_action_pressed("ui_left"):
		offset.x -= 1
	if Input.is_action_pressed("ui_down"):
		offset.y += 1
	if Input.is_action_pressed("ui_up"):
		offset.y -= 1
