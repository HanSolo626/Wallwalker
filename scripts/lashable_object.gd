extends RigidBody3D


var speed: float = 0.1
var target = Vector3(0, 0, 0)
var target_dir
var inital_distance = 0
var attraction_force_speed = 50
var lock_force = 100
var lock_time = 9999999
var timer = 0
var parent_lash_timer = 0
var slow_down_fraction = 1

var child_bound = false

var last_lash_position = Vector3(0, 0, 0)

var lashing_parent
var last_parent_origin

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var being_lashed = false
var glowing = false
var orgininal_material

var platform_target_reference
var inital_platform_reference
var inital_target_position

var lashing_effect



@onready var collision = $Collision
@onready var body = $Body



		
func set_target(new_target):
	set_glow(true)
	if typeof(new_target) == TYPE_VECTOR3:
		if child_bound:
			var t = global_transform
			var g = get_tree()
			lashing_parent.remove_child(self)
			g.current_scene.add_child(self)
			child_bound = false
			global_transform = t
		target = new_target
		lashing_parent = null
		inital_distance = transform.origin.distance_to(target)

	else:
		lashing_parent = new_target
		var t = global_transform
		if not self in lashing_parent.get_children():
			get_tree().current_scene.remove_child(self)
			lashing_parent.add_child(self)
		child_bound = true
		global_transform = t
	last_lash_position = Vector3(0,0,0)
	being_lashed = true
	platform_target_reference = null
	
func set_target_platform(target_position: Vector3, target_platform):
	set_glow(true)
	if child_bound:
		var t = global_transform
		var g = get_tree()
		lashing_parent.remove_child(self)
		g.current_scene.add_child(self)
		child_bound = false
		global_transform = t
	platform_target_reference = target_platform
	inital_platform_reference = target_platform.global_transform.origin
	target = target_position
	inital_target_position = target_position
	lashing_parent = null
	inital_distance = transform.origin.distance_to(target)
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
	if a.snapped(Vector3(0.1, 0.1, 0.1)) == b.snapped(Vector3(0.1, 0.1, 0.1)):
		return true
	else:
		return false
		
func lashings_off():
	being_lashed = false
	set_glow(false)
		
func set_glow(value: bool):
	if value and not glowing:
		#body.mesh.material.albedo_color.b = 5
		#body.mesh.material.albedo_color.r = 1.5
		#body.mesh.material.albedo_color.g = 1.5
		add_child(preload("res://scenes/lashing_effect.tscn").instantiate())
		glowing = true
		
	elif not value and glowing:
		#body.mesh.material = orgininal_material.duplicate()
		get_child(-1).queue_free()
		glowing = false
		#body.mesh.material.emission_enabeld = false
		
func is_lashable_object():
	return true
		
		
func _ready():
	body.mesh.material = body.mesh.material.duplicate()
	orgininal_material = body.mesh.material.duplicate()
	

func _physics_process(delta):
	if being_lashed:
		
		if platform_target_reference != null:
			target = (platform_target_reference.global_transform.origin - inital_platform_reference) + inital_target_position
		elif lashing_parent != null:
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
		
		if child_bound:
			var t = global_transform
			var g = get_tree()
			lashing_parent.remove_child(self)
			g.current_scene.add_child(self)
			child_bound = false
			global_transform = t


func _on_collision_detection_body_entered(body_t):
	# if it works, is a dumb idea?
	if being_lashed and body_t.being_lashed and body_t != self:
		lashings_off()
		body_t.lashings_off()
		
		
		
