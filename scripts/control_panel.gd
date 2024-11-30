extends StaticBody3D


var player_present = false
var being_lashed = false
var num_id = 0

func set_id(num: int):
	num_id = num
	return num_id
	
func get_id():
	return num_id


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_detection_body_entered(body):
	player_present = true


func _on_player_detection_body_exited(body):
	player_present = false
