extends Control
@onready var load_dungeon = $"MarginContainer/VBoxContainer/Load Dungeon"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta):
	print(InputEventMouseButton.new().pressed)


func _on_exit_pressed():
	get_tree().quit()


func _on_load_dungeon_pressed():
	get_tree().change_scene_to_file("res://scenes/select_level_menu.tscn")
	


func _on_load_dungeon_mouse_entered():
	print("mouse entered play button")
