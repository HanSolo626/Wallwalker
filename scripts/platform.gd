extends CharacterBody3D


var current_glide_position: Vector3
var current_glide_speed: float
var current_glide_time: float

var timer = 0


func is_platform():
	return true
	
func move_instantly_to_position(pos: Vector3):
	transform.origin = pos
	
func glide_to_position(pos: Vector3, speed: float, time: float):
	current_glide_position = pos
	current_glide_speed = speed
	current_glide_time = time
	timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	timer += delta
	if timer < current_glide_time:
		position += current_glide_position * current_glide_speed
		
