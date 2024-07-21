extends CharacterBody3D


@onready var area3d = $Area3D
const SPEED = 6.0
const HEIGHT = 12.0
var current_y_position = 0
var START_POSITION
var FACING_NORTH
var going_down = true





func init_door(start_position, facing_north: bool):
	START_POSITION = start_position
	FACING_NORTH = facing_north
	
	if not FACING_NORTH:
		rotate_y(deg_to_rad(90.0))
		
	transform.origin = START_POSITION
		
	



func _physics_process(_delta):
	if going_down:
		if transform.origin.y <= START_POSITION.y:
			#transform.origin = START_POSITION
			velocity.y = 0
		else:
			velocity.y = -SPEED
	else:
		if transform.origin.y >= HEIGHT:
			velocity.y = 0
		else:
			velocity.y = SPEED
		
	move_and_slide()


func _on_area_3d_body_entered(_body):
	going_down = false
		

func _on_area_3d_body_exited(_body):
	going_down = true
		

