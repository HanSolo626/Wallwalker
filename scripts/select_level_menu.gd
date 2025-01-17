extends Control

@onready var v_box_container = $VScrollBar/VBoxContainer

var banned_levels = ["lashing_binding_test_area", "level_1", "level_template"]
var ban_levels = false

func dir_contents(path):
	var level_list = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				level_list.append(file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	if ban_levels:
		for level in level_list:
			if level in banned_levels:
				level_list.erase(level)
	return level_list




func _ready():
	var levels = dir_contents("res://alpha_levels")
	for level_name in levels:
		var button = Button.new()
		button.name = level_name
		button.text = level_name
		button.pressed.connect(_on_button_pressed.bind(button))
		v_box_container.add_child(button)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	
func _on_button_pressed(button):
	var a = button.name
	get_tree().change_scene_to_file("res://alpha_levels/"+str(a)+"/"+str(a)+".tscn")


func _on_return_to_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
