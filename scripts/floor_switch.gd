extends StaticBody3D


var player_present = false
var being_lashed = false
var num_id = 0
var glowing = true

@onready var decal = $MeshInstance3D/Decal

func set_glowing_on():
	if not glowing:
		glowing = true
		decal.emission_energy = 0.05
		decal.modulate = Color(2, 2, 15)
		
func set_glowing_off():
	if glowing:
		glowing = false
		decal.emission_energy = 0
		decal.modulate = Color(0,0,0)

func set_id(num: int):
	num_id = num
	return num_id
	
func get_id():
	return num_id


# Called when the node enters the scene tree for the first time.
func _ready():
	set_glowing_off()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_detection_body_entered(body):
	player_present = true
	set_glowing_on()


func _on_player_detection_body_exited(body):
	player_present = false
	set_glowing_off()
