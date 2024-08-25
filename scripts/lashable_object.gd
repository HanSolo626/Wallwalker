extends RigidBody3D


var speed: float = 0.1
var target = Vector3(0, 0, 0)
var target_dir
var attraction_force_speed = 50
var lock_force = 150
var lock_time = 2.5
var timer = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var being_lashed = false


@onready var collision = $Collision



		
func set_target(new_target: Vector3):
	target = new_target
	being_lashed = true
	
func get_min_collision_size(c):
	var result = c.shape.size.x
	if result > c.shape.size.y:
		result = c.shape.size.y
	if result > c.shape.size.z:
		result = c.shape.size.z
	return result
	
	

func _physics_process(delta):
	target_dir = (target - global_transform.origin).normalized()
	if being_lashed:
		if transform.origin.distance_to(target) > get_min_collision_size(collision) - 0.0:
			apply_force((target_dir * attraction_force_speed))
			gravity_scale = 0
			freeze = false
			timer = 0
		else:
			timer += delta
			if timer > lock_time:
				freeze = true
			else:
				apply_force((target_dir * lock_force))
				gravity_scale = 0
	else:
		gravity_scale = 1
		freeze = false
		timer = 0
