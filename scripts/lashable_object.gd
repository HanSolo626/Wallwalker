extends RigidBody3D


var speed: float = 0.1
var target = Vector3(0, 0, 0)
var target_dir
var inital_distance = 0
var attraction_force_speed = 50
var lock_force = 225
var lock_time = 0.2
var timer = 0
var parent_lash_timer = 0
var slow_down_fraction = 1

var last_lash_position = Vector3(0, 0, 0)

var lashing_parent
var last_parent_origin

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var being_lashed = false


@onready var collision = $Collision



		
func set_target(new_target):
	if typeof(new_target) == TYPE_VECTOR3:
		target = new_target
		lashing_parent = null
		inital_distance = transform.origin.distance_to(target)
	else:
		lashing_parent = new_target
		var t = global_transform
		get_tree().current_scene.remove_child(self)
		lashing_parent.add_child(self)
		global_transform = t
	last_lash_position = Vector3(0,0,0)
	being_lashed = true
	
func get_min_collision_size():
	var result = collision.shape.size.x
	if result > collision.shape.size.y:
		result = collision.shape.size.y
	if result > collision.shape.size.z:
		result = collision.shape.size.z
	
	if lashing_parent != null:
		result += (lashing_parent.get_max_collision_size() / 2)
	return result
	
func get_max_collision_size():
	var result = collision.shape.size.x
	if result < collision.shape.size.y:
		result = collision.shape.size.y
	if result < collision.shape.size.z:
		result = collision.shape.size.z
	return result
	
func vectors_are_approx_equal(a: Vector3, b: Vector3):
	if a.snapped(Vector3(0.01, 0.01, 0.01)) == b.snapped(Vector3(0.01, 0.01, 0.01)):
		return true
	else:
		return false
	
	

func _physics_process(delta):
	if being_lashed:
		if lashing_parent != null:
			target = lashing_parent.global_transform.origin
			
		target_dir = (target - global_transform.origin).normalized()
		
		if transform.origin.distance_to(target) > get_min_collision_size():
			if transform.origin.distance_to(target) <= inital_distance / 2:
				slow_down_fraction = transform.origin.distance_to(target) / (inital_distance / 2)
				#if slow_down_fraction < 0.5:
				#	apply_force(target_dir * attraction_force_speed * mass * (slow_down_fraction - 1))
			else:
				slow_down_fraction = 1
			apply_force((target_dir * attraction_force_speed * mass * slow_down_fraction))
			gravity_scale = 0
			freeze = false
			timer = 0
		else:
			timer += delta
			if lashing_parent == null and timer > lock_time:
				print(last_lash_position)
				print(global_transform.origin)
				if vectors_are_approx_equal(global_transform.origin, last_lash_position):
					freeze = true
					print("freeze")
				else:
					timer = 0
					last_lash_position = global_transform.origin
			else:
				apply_force((target_dir * lock_force * mass))
				gravity_scale = 0
				freeze = false
			if last_lash_position != Vector3(0,0,0):
				last_lash_position = global_transform.origin
	else:
		gravity_scale = 1
		freeze = false
		timer = 0
