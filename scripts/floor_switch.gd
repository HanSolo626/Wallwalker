extends StaticBody3D


var being_lashed = false
var num_id = 0
var glowing = true
var objects_present = 0

@onready var decal = $MeshInstance3D/Decal

signal activated
signal deactivated

func set_glowing_on():
	if not glowing:
		glowing = true
		decal.emission_energy = 0.05
		decal.modulate = Color(2, 2, 15)
		
func set_glowing_off():
	if glowing:
		glowing = false
		decal.emission_energy = 0
		decal.modulate = Color(0.5, 0.5, 0.5)

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
	objects_present += 1
	if objects_present != 0:
		set_glowing_on()
		activated.emit()


func _on_player_detection_body_exited(body):
	objects_present -= 1
	if objects_present == 0:
		set_glowing_off()
		deactivated.emit()
