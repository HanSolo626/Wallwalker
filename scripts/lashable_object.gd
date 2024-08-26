extends RigidBody3D


var speed: float = 0.1
var target = Vector3(0, 0, 0)
var target_dir
var attraction_force_speed = 50
var lock_force = 150
var lock_time = 2.5
var timer = 0
var parent_lash_timer = 0

var lashing_parent
var last_parent_origin

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var being_lashed = false


@onready var collision = $Collision



		
func set_target(new_target):
	if typeof(new_target) == TYPE_VECTOR3:
		target = new_target
		lashing_parent = null
	else:
		lashing_parent = new_target
		var t = global_transform
		get_tree().current_scene.remove_child(self)
		lashing_parent.add_child(self)
		global_transform = t
		
	being_lashed = true
	
func get_min_collision_size(c):
	var result = c.shape.size.x
	if result > c.shape.size.y:
		result = c.shape.size.y
	if result > c.shape.size.z:
		result = c.shape.size.z
	return result
	
	

func _physics_process(delta):
	if being_lashed:
		if lashing_parent != null:
			target = lashing_parent.global_transform.origin
			
		target_dir = (target - global_transform.origin).normalized()
		
		if transform.origin.distance_to(target) > get_min_collision_size(collision):
			apply_force((target_dir * attraction_force_speed * mass))
			gravity_scale = 0
			freeze = false
			timer = 0
		else:
			timer += delta
			if lashing_parent == null and timer > lock_time:
				freeze = true
			else:
				apply_force((target_dir * lock_force * mass))
				gravity_scale = 0
				freeze = false
	else:
		gravity_scale = 1
		freeze = false
		timer = 0
	
