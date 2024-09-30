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

var lash_direction = 0
var rotation_error_margin = deg_to_rad(0.1)

var lashing_parent
var last_parent_origin

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var being_lashed = false



@onready var collision = $Collision



		
func set_target(new_target, raycast_object):
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
	
	if raycast_object != null:
		# get points
		var block = raycast_object.get_collision_point() - raycast_object.get_collision_normal()
		var face = raycast_object.get_collision_point() + raycast_object.get_collision_normal()

		
		# extract direction
		if block.x - face.x < 0 or block.x - face.x > 0:
			lash_direction = 1
			
			
		elif block.y - face.y < 0 or block.y - face.y > 0:
			lash_direction = 2
			
			
		elif block.z - face.z < 0 or block.z - face.z > 0:
			lash_direction = 3
	else:
		lash_direction = 0
		
		

	
	
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
	if a.snapped(Vector3(0.1, 0.1, 0.1)) == b.snapped(Vector3(0.1, 0.1, 0.1)):
		if (
			lash_direction == 1 and
			abs(deg_to_rad(rotation.z)) >= get_relative_measure_angle(rotation.z) - rotation_error_margin and
			abs(deg_to_rad(rotation.z)) <= get_relative_measure_angle(rotation.z) + rotation_error_margin
			):
			return true
		elif (
			lash_direction == 2 and 
			abs(deg_to_rad(rotation.x)) >= get_relative_measure_angle(rotation.x) - rotation_error_margin and
			abs(deg_to_rad(rotation.x)) <= get_relative_measure_angle(rotation.x) + rotation_error_margin
			):
			print(abs(deg_to_rad(rotation.x)), get_relative_measure_angle(rotation.x) - rotation_error_margin)
			print(abs(deg_to_rad(rotation.x)), get_relative_measure_angle(rotation.x) + rotation_error_margin)
			return true
		elif (
			lash_direction == 3 and 
			abs(deg_to_rad(rotation.y)) >= get_relative_measure_angle(rotation.y) - rotation_error_margin and 
			abs(deg_to_rad(rotation.y)) <= get_relative_measure_angle(rotation.y) + rotation_error_margin
			):
			return true
		else:
			return false
	else:
		return false
		
func get_relative_measure_angle(angle: float):
	angle = abs(deg_to_rad(angle))
	var result
	if angle > 45.0:
		result = 90.0
	if angle > 135.0:
		result = 180
	if angle < 45.0:
		result = 0.0
	else:
		result = 90.0
	return deg_to_rad(result)
	
	

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
				#print(last_lash_position)
				#print(global_transform.origin)
				if vectors_are_approx_equal(global_transform.origin, last_lash_position):
					freeze = true
					#print("freeze")
				else:
					timer = 0
					last_lash_position = global_transform.origin
			elif lashing_parent != null:
				if vectors_are_approx_equal(global_position, last_lash_position):
					freeze = true
				else:
					timer = 0
					last_lash_position = global_position
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
