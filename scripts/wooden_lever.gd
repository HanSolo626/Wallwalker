extends StaticBody3D

@onready var lever_hinge = $LeverHinge

var on = false
var speed = 1
var player_present = false
var moving = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		if on:
			if lever_hinge.rotation.x > deg_to_rad(-30):
				lever_hinge.rotate_x(-speed * delta)
				print(lever_hinge.rotation.x)
			else:
				lever_hinge.rotation.x = deg_to_rad(-30)
				moving = false
		else:
			if lever_hinge.rotation.x < deg_to_rad(30):
				lever_hinge.rotate_x(speed * delta)
				print(lever_hinge.rotation.x)
			else:
				lever_hinge.rotation.x = deg_to_rad(30)
				moving = false


func _on_player_detection_body_entered(body):
	player_present = true
	on = true
	moving = true
	

func _on_player_detection_body_exited(body):
	player_present = false
	on = false
	moving = true
