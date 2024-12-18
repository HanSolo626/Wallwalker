extends CharacterBody3D


var current_glide_position: Vector3
var current_glide_loop_positions: Array
var current_glide_speed: float
var current_glide_time: float
var moving = false

var one_time_timer = 0
var loop_timer = 0
var timer = 0
#					  -X    +X    -Y    +Y    -Z    +Z
var lashable_faces = [true, true, true, true, true, true]


@onready var collision = $Collision



func is_platform():
	return true
	
func move_instantly_to_position(pos: Vector3):
	global_transform.origin = pos
	
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
	
func glide_up(y: float, speed: float):
	current_glide_position = transform.basis.y * y
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
func glide_down(y: float, speed: float):
	current_glide_position = transform.basis.y * -y
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
func glide_left(x: float, speed: float):
	current_glide_position = transform.basis.x * -x
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
func glide_right(x: float, speed: float):
	current_glide_position = transform.basis.x * x
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
func glide_forward(z: float, speed: float):
	current_glide_position = transform.basis.z * z
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
func glide_backward(z: float, speed: float):
	current_glide_position = transform.basis.z * -z
	current_glide_speed = speed
	current_glide_loop_positions = []
	moving = true
	
	
func get_max_collision_size():
	var result = collision.shape.size.x
	if result < collision.shape.size.y:
		result = collision.shape.size.y
	if result < collision.shape.size.z:
		result = collision.shape.size.z
	return result
	
func prep_lashing_settings():
	lashable_faces[0] = get_meta("minus_x_lash")
	lashable_faces[1] = get_meta("plus_x_lash")
	lashable_faces[2] = get_meta("minus_y_lash")
	lashable_faces[3] = get_meta("plus_y_lash")
	lashable_faces[4] = get_meta("minus_z_lash")
	lashable_faces[5] = get_meta("plus_z_lash")
	
func get_surface_lashable(index: int):
	return lashable_faces[index]

func _ready():
	prep_lashing_settings()


func _physics_process(delta):
	timer += delta
	if moving and not round(current_glide_position).is_equal_approx(round(position)):
		if timer >= loop_timer:
			global_position += (current_glide_position - global_position).normalized() * current_glide_speed
	elif current_glide_loop_positions != []:
		if current_glide_loop_positions.find(current_glide_position) == current_glide_loop_positions.size()-1:
			current_glide_position = current_glide_loop_positions[0]
		else:
			current_glide_position = current_glide_loop_positions[current_glide_loop_positions.find(current_glide_position)+1]
		timer = 0
	else:
		moving = false
		
