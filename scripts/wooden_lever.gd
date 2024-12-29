extends StaticBody3D


var on = false
var speed = 1
var player_present = false
var moving = false
var disabled = false


@onready var lever_hinge = $LeverHinge
@onready var label_3d = $Label3D


func set_lever_on():
	on = true
	moving = true
	
func set_lever_off():
	on = false
	moving = true
	
func flip_lever():
	on = !on
	moving = true
	
func get_lever_status():
	return on
	
func set_enabled():
	disabled = false
	if player_present:
		label_3d.show()
		
func set_disabled():
	disabled = true
	label_3d.hide()
	
	

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
	if not disabled:
		label_3d.show()
	

func _on_player_detection_body_exited(body):
	player_present = false
	if not disabled:
		label_3d.hide()
