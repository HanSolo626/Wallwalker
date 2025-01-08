extends Control

@onready var return_to_main_menu_button = $VBoxContainer/ReturnToMainMenuButton

func activate():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func _on_return_to_main_menu_button_button_down():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
