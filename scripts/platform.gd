extends CharacterBody3D


var current_glide_position: Vector3
var current_glide_loop_positions: Array
var current_glide_speed: float
var current_glide_time: float
var moving = false

var one_time_timer = 0
var loop_timer = 0
var timer = 0
@onready var collision = $Collision


func is_platform():
	return true
	
func move_instantly_to_position(pos: Vector3):
	transform.origin = pos
	
func glide_to_position(pos: Vector3, speed: float):
	current_glide_position = pos
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
	
func glide_in_loop(pos_array: Array, speed: float, pause_time: float):
	current_glide_loop_positions = pos_array
	current_glide_position = pos_array[0]
	current_glide_speed = speed
	loop_timer = pause_time
	moving = true
	
	
func get_max_collision_size():
	var result = collision.shape.size.x
	if result < collision.shape.size.y:
		result = collision.shape.size.y
	if result < collision.shape.size.z:
		result = collision.shape.size.z
	return result
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	timer += delta
	if moving and not round(current_glide_position).is_equal_approx(round(position)):
		if timer >= loop_timer:
			position += (current_glide_position - position).normalized() * current_glide_speed
	elif current_glide_loop_positions != []:
		if current_glide_loop_positions.find(current_glide_position) == current_glide_loop_positions.size()-1:
			current_glide_position = current_glide_loop_positions[0]
		else:
			current_glide_position = current_glide_loop_positions[current_glide_loop_positions.find(current_glide_position)+1]
		timer = 0
	else:
		moving = false
		
