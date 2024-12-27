extends Control

@onready var v_box_container = $VBoxContainer




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
	return level_list



# Called when the node enters the scene tree for the first time.
func _ready():
	var levels = dir_contents("res://alpha_levels")
	var iteration = 0
	for name in levels:
		var button = Button.new()
		button.name = "B"+str(iteration)
		button.text = name
		v_box_container.add_child(button)
		iteration += 1
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
