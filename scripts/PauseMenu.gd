extends Control



func _process(delta):
	# Check for pause
	if Input.is_action_just_pressed("quit"):
		if get_tree().paused == true:
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			hide()
		else:
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			show()
			print(has_focus())
		


func _on_resume_button_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()


func _on_exit_to_main_menu_button_pressed():
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_exit_game_button_pressed():
	get_tree().quit()
