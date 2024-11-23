extends StaticBody3D

var open = false
var door_moving = false
var door_speed = 1.0
var door_open_height = 100.0

func open_door():
	door_moving = true
	open = true
	
func close_door():
	door_moving = true
	open = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if door_moving:
		if open and door_open_height >= transform.origin.y:
			door_moving = false
		if not open and 0 <= transform.origin.y:
			door_moving = false
			
		if open:
			translate_object_local(Vector3(0,door_speed,0))
		else:
			translate_object_local(Vector3(0,-door_speed,0))
			
