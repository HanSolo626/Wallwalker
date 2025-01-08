extends CharacterBody3D


# 1: Personal Gravity
# 2: Bind objects
var lashing_mode = 1

# lashing count
var lashing_count = 0
var max_lashings = 1

var max_lashing_mode_num = 2
var object_to_bind
var currently_bound_object


const WALKING_SPEED = 8.0
const WALKING_ACC = 1.0
const SPRINT_SPEED = 15.0
const CROUCH_SPEED = 3.0
const SPRINT_ACC = 1.5
const JUMP_VELOCITY = 12
const SLOWDOWN_CHANGE = 1.0
# the smaller this value, the faster it goes
const CAMERA_ROTATION_SPEED = 25
var light_on = false
var frozen = false

var crouching = false
var dead = false
var health = 100
var recovery_rate = 3.5

# Get the gravity from the project settings to be synced with RigidBody nodes. (nope!)
var gravity = 24.0
var sensitivity = 0.0015
var current_pull = 1
var positive = false
var dir_str = "floor"
var rotation_trigger = true

var x_to_set = 0.0
var y_to_set = 0.0
var z_to_set = 0.0
var x_updates = 0
var y_updates = 0
var z_updates = 0


var resolve_binding = true


# Camera angle data
const CAMERA_ANGLES = {
	"floor":{
		"up":[180, null, null],
		"down":null,
		"left":[null, null, -90],
		"right":[null, null, 90],
		"forward":[-90, null, null],
		"backward":[90, null, null]
	},
	"ceiling":{
		"up":null,
		"down":[0, null, null],
		"left":[null, null, 90],
		"right":[null, null, -90],
		"forward":[90, null, null],
		"backward":[-90, null, null]
	},
	"left wall":{
		"up":[null, null, -90],
		"down":[null, null, 90],
		"left":null,
		"right":[null, 180, null],
		"forward":[null, 90, null],
		"backward":[null, -90, null]
	},
	"right wall":{
		"up":[null, null, 90],
		"down":[null, null, -90],
		"left":[null, 180, null],
		"right":null,
		"forward":[null, -90, null],
		"backward":[null, 90, null]
	},
	"forward wall":{
		"up":[-90, null, null],
		"down":[90, null, null],
		"left":[null, -90, null],
		"right":[null, 90, null],
		"forward":null,
		"backward":[null, 180, null]
	},
	"backward wall":{
		"up":[90, null, null],
		"down":[-90, null, null],
		"left":[null, 90, null],
		"right":[null, -90, null],
		"forward":[null, 180, null],
		"backward":null
	},
}


signal player_killed
signal control_clicked
signal action_key_pressed

@onready var camera_3d = $Camera3D
@onready var lashing_ray_cast = $Camera3D/LashingRayCast
@onready var binding_ray_cast = $Camera3D/BindingRayCast
@onready var normal_collision = $NormalCollision
@onready var crouching_collision = $CrouchingCollision
@onready var body = $Body
@onready var stick = $stick
#@onready var gridmap = $"../DungeonGridMap"
@onready var flashlight = $Camera3D/SpotLight3D
@onready var crouch_checker = $CrouchChecker
@onready var user_interface = $"../Control/UserInterface"
@onready var control_ray_cast = $Camera3D/ControlRayCast

@onready var yellow_sphere = $Camera3D/"fps-hands"/YellowSphere
@onready var green_sphere = $Camera3D/"fps-hands"/GreenSphere
@onready var fps_hands = $"Camera3D/fps-hands"
@onready var lashing_sound = $LashingSound
@onready var cancel_lashing_sound = $CancelLashingSound
@onready var binding_sound = $BindingSound


func set_top_level(t):
	camera_3d.top_level = t
	normal_collision.top_level = t
	crouching_collision.top_level = t
	body.top_level = t
	stick.top_level = t

func is_rotating():
	if x_updates <= 0 and y_updates <= 0 and z_updates <= 0:
		return false
	else:
		return true

func update_rotation():
	if rotation_trigger:
		if y_updates > 0:
			rotate_y(y_to_set)
			y_updates -= 1
			
		if x_updates > 0:
			rotate_x(x_to_set)
			x_updates -= 1
			
		if z_updates > 0:
			rotate_z(z_to_set)
			z_updates -= 1
	


func arm_rotation_change(data):
	
	
	var x = data[0]
	var y = data[1]
	var z = data[2]
	rotation_trigger = false

	if x == null:
		pass
	else:
		if x == 0:
			if rotation.z < 0:
				x_to_set = rotation.z / CAMERA_ROTATION_SPEED
			else: 
				x_to_set = -rotation.z / CAMERA_ROTATION_SPEED
		else:
			x_to_set = deg_to_rad(x) / CAMERA_ROTATION_SPEED
		x_updates = CAMERA_ROTATION_SPEED
	
	if y == null:
		pass
	else:
		if y == 0:
			if rotation.z < 0:
				y_to_set = rotation.z / CAMERA_ROTATION_SPEED
			else:
				y_to_set = -rotation.z / CAMERA_ROTATION_SPEED
		else:
			y_to_set = deg_to_rad(y) / CAMERA_ROTATION_SPEED
		y_updates = CAMERA_ROTATION_SPEED
	
	if z == null:
		pass
	else:
		if z == 0:
			if rotation.x < 0:
				z_to_set = rotation.x / CAMERA_ROTATION_SPEED
			else:
				z_to_set = -rotation.x / CAMERA_ROTATION_SPEED
		else:
			z_to_set = deg_to_rad(z) / CAMERA_ROTATION_SPEED
		z_updates = CAMERA_ROTATION_SPEED
		
		
	
	print("X: "+str(x_to_set)+" Y: "+str(y_to_set)+" Z: "+str(z_to_set))
	


func change_gravity(raycast_object: RayCast3D):
	# get points
	var block = raycast_object.get_collision_point() - raycast_object.get_collision_normal()
	var face = raycast_object.get_collision_point() + raycast_object.get_collision_normal()
	
	var lashed_object = raycast_object.get_collider()
	
	# extract direction
	# x = 0
	# y = 1
	# z = 2
	
	# TODO fix if/else gates
	if block.x - face.x < 0 and (current_pull != 0 or positive != false):
		if lashed_object.has_method("glide_in_loop") and not lashed_object.get_surface_lashable(0):
			pass
		else:
			change_gravity_left()
			mod_lashing_count(-1)
			mod_lashing_count(1)
		
	elif block.x - face.x > 0 and (current_pull != 0 or positive != true):
		if lashed_object.has_method("glide_in_loop") and not lashed_object.get_surface_lashable(1):
			pass
		else:
			change_gravity_right()
			mod_lashing_count(-1)
			mod_lashing_count(1)
		
		
	elif block.y - face.y < 0 and (current_pull != 1 or positive != false):
		if lashed_object.has_method("glide_in_loop") and not lashed_object.get_surface_lashable(2):
			pass
		else:
			change_gravity_down()
			mod_lashing_count(-1)
		
		
	elif block.y - face.y > 0 and (current_pull != 1 or positive != true):
		if lashed_object.has_method("glide_in_loop") and not lashed_object.get_surface_lashable(3):
			pass
		else:
			change_gravity_up()
			mod_lashing_count(-1)
			mod_lashing_count(1)
		
	elif block.z - face.z < 0 and (current_pull != 2 or positive != false):
		if lashed_object.has_method("glide_in_loop") and not lashed_object.get_surface_lashable(4):
			pass
		else:
			change_gravity_backward()
			mod_lashing_count(-1)
			mod_lashing_count(1)
		
	elif block.z - face.z > 0 and (current_pull != 2 or positive != true):
		if lashed_object.has_method("glide_in_loop") and not lashed_object.get_surface_lashable(5):
			pass
		else:
			change_gravity_forward()
			mod_lashing_count(-1)
			mod_lashing_count(1)
		
		
		
		
func change_gravity_left():
	if CAMERA_ANGLES[dir_str]["left"] != null:
		lashing_sound.play()
		print("left")
		current_pull = 0
		positive = false
		arm_rotation_change(CAMERA_ANGLES[dir_str]["left"])
		dir_str = "left wall"
		up_direction = Vector3.RIGHT
		check_crouch_needed(Vector3.RIGHT)
	
func change_gravity_right():
	if CAMERA_ANGLES[dir_str]["right"] != null:
		lashing_sound.play()
		print("right")
		current_pull = 0
		positive = true
		arm_rotation_change(CAMERA_ANGLES[dir_str]["right"])
		dir_str = "right wall"
		up_direction = Vector3.LEFT
		check_crouch_needed(Vector3.LEFT)
	
func change_gravity_down():
	if CAMERA_ANGLES[dir_str]["down"]:
		cancel_lashing_sound.play()
		print("down")
		current_pull = 1
		positive = false
		arm_rotation_change(CAMERA_ANGLES[dir_str]["down"])
		dir_str = "floor"
		up_direction = Vector3.UP
		check_crouch_needed(Vector3.UP)
	
func change_gravity_up():
	if CAMERA_ANGLES[dir_str]["up"] != null:
		lashing_sound.play()
		print("up")
		current_pull = 1
		positive = true
		arm_rotation_change(CAMERA_ANGLES[dir_str]["up"])
		dir_str = "ceiling"
		up_direction = Vector3.DOWN
		check_crouch_needed(Vector3.DOWN)
	
func change_gravity_forward():
	if CAMERA_ANGLES[dir_str]["forward"]:
		lashing_sound.play()
		print("forward")
		current_pull = 2
		positive = true
		arm_rotation_change(CAMERA_ANGLES[dir_str]["forward"])
		dir_str = "forward wall"
		up_direction = Vector3.FORWARD
		check_crouch_needed(Vector3.BACK)

func change_gravity_backward():
	if CAMERA_ANGLES[dir_str]["backward"]:
		lashing_sound.play()
		print("backward")
		current_pull = 2
		positive = false
		arm_rotation_change(CAMERA_ANGLES[dir_str]["backward"])
		dir_str = "backward wall"
		up_direction = Vector3.BACK
		check_crouch_needed(Vector3.FORWARD)
	
		
func check_crouch_needed(direction: Vector3):
	if check_ceiling(direction):
		enable_crouching()
		

func check_ceiling(direction: Vector3):
	var a = false
	# perform raycast
	var space_state = get_world_3d().direct_space_state
	var end = transform.origin + direction * 2
	var query = PhysicsRayQueryParameters3D.create(transform.origin, end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result != {}:
		a = true
	return a
	

		
func enable_crouching():
	if crouching != true:
		crouching = true
		normal_collision.disabled = true
		crouching_collision.disabled = false
		camera_3d.transform.origin = Vector3(0, 0.5, 0)
		translate_object_local(Vector3(0, -1, 0))
		fps_hands.translate_object_local((Vector3(0, 1.5, 0)))
	
func disable_crouching():
	if crouching != false and not crouch_checker.is_colliding():
		crouching = false
		normal_collision.disabled = false
		crouching_collision.disabled = true
		camera_3d.transform.origin = Vector3(0, 1.5, 0)
		translate_object_local(Vector3(0, 1, 0))
		fps_hands.translate_object_local((Vector3(0, -1.5, 0)))
		
func slow_down_player(value):
	if value > 0:
		if value > SLOWDOWN_CHANGE:
			value -= SLOWDOWN_CHANGE
		else:
			value = 0
	else:
		if abs(value) > SLOWDOWN_CHANGE:
			value += SLOWDOWN_CHANGE
		else:
			value = 0
	return value
	
func speed_up_player(value, dir, acc, max_speed):
	if dir > 0:
		if value < dir * max_speed:
			value += acc
		else:
			value = dir * max_speed
	else:
		if abs(value) < abs(dir * max_speed):
			value -= acc
		else:
			value = dir * max_speed
	return value


func freeze_player():
	if frozen:
		frozen = false
	else:
		frozen = true
		
func mod_lashing_count(num: int):
	if lashing_count + num <= max_lashings:
		lashing_count += num
		if lashing_count < 0:
			lashing_count = 0
	else:
		lashing_count = max_lashings
		


func _ready(): # setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_top_level(false)
	#change_rotation(CAMERA_ANGLES["left wall"]["left"])
	
	#transform.origin = gridmap.get_player_start_location()
	
	
	
func _input(event):
	# Mouse input
	if not frozen and event is InputEventMouseMotion and is_rotating() == false:
		if positive:
			if current_pull == 0:
				rotate_x(event.relative.x * sensitivity)
				camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * sensitivity
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad((90)))
			elif current_pull == 1:
				rotation.y = rotation.y + event.relative.x * sensitivity
				camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * sensitivity
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad((90)))
			elif current_pull == 2:
				rotate_z(event.relative.x * sensitivity)
				camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * sensitivity
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad((90)))
			
		else:
			if current_pull == 0:
				rotate_x(-event.relative.x * sensitivity)
				camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * sensitivity
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad((90)))
			elif current_pull == 1:
				rotation.y = rotation.y - event.relative.x * sensitivity
				camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * sensitivity
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad((90)))
			elif current_pull == 2:
				rotate_z(-event.relative.x * sensitivity)
				camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * sensitivity
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad((90)))
			


func _physics_process(delta):
	
		
	# Add the gravity.
	if positive:
		if current_pull == 0: # X
			velocity.x += gravity * delta
		elif current_pull == 1: # Y
			velocity.y += gravity * delta
		elif current_pull == 2: # X
			velocity.z += gravity * delta
	else:
		if current_pull == 0: # X
			velocity.x -= gravity * delta
		elif current_pull == 1: # Y
			velocity.y -= gravity * delta
		elif current_pull == 2: # X
			velocity.z -= gravity * delta

	# Handle jump.
	if not dead and not frozen and not crouching and Input.is_action_just_pressed("jump") and is_on_floor():
		if not positive:
			if current_pull == 0: # X
				velocity.x = JUMP_VELOCITY
			elif current_pull == 1: # Y
				velocity.y = JUMP_VELOCITY
			elif current_pull == 2: # z
				velocity.z = JUMP_VELOCITY
		else:
			if current_pull == 0: # X
				velocity.x = -JUMP_VELOCITY
			elif current_pull == 1: # Y
				velocity.y = -JUMP_VELOCITY
			elif current_pull == 2: # z
				velocity.z = -JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var multiplyer
	var acceleration
	
	if crouching:
		multiplyer = CROUCH_SPEED
		acceleration = WALKING_ACC
	elif Input.is_action_pressed("shift_key"):
		multiplyer = SPRINT_SPEED
		acceleration = SPRINT_ACC
	else:
		multiplyer = WALKING_SPEED
		acceleration = WALKING_ACC
		
	if not dead and not frozen and direction:
		if current_pull == 0: # X
			velocity.y = speed_up_player(velocity.y, direction.y, acceleration, multiplyer)
			velocity.z = speed_up_player(velocity.z, direction.z, acceleration, multiplyer)
		elif current_pull == 1: # Y
			velocity.x = speed_up_player(velocity.x, direction.x, acceleration, multiplyer)
			velocity.z = speed_up_player(velocity.z, direction.z, acceleration, multiplyer)
		elif current_pull == 2: # Z
			velocity.y = speed_up_player(velocity.y, direction.y, acceleration, multiplyer)
			velocity.x = speed_up_player(velocity.x, direction.x, acceleration, multiplyer)
	else:
		if current_pull == 0 and (is_on_floor()): # X
			velocity.y = slow_down_player(velocity.y)
			velocity.z = slow_down_player(velocity.z)
			rotation_trigger = true
		elif current_pull == 1 and (is_on_floor() or is_on_ceiling()): # Y
			velocity.x = slow_down_player(velocity.x)
			velocity.z = slow_down_player(velocity.z)
			rotation_trigger = true
		elif current_pull == 2 and (is_on_floor()): # Z
			velocity.y = slow_down_player(velocity.y)
			velocity.x = slow_down_player(velocity.x)
			rotation_trigger = true
			
		
		
	# handle mouse clicks
	if not dead and not frozen and (Input.is_action_just_pressed("lash") or Input.is_action_just_pressed("bind")):
		if lashing_ray_cast.is_colliding() or binding_ray_cast.is_colliding():
			print(lashing_ray_cast.get_collider())
			
			# LASH
			if Input.is_action_just_pressed("lash") and lashing_ray_cast.get_collider() != null and (lashing_ray_cast.get_collider().has_method("is_grid_map") or lashing_ray_cast.get_collider().has_method("is_platform")) and is_rotating() == false:
				if lashing_count == max_lashings and currently_bound_object != null:
					currently_bound_object.lashings_off()
				change_gravity(lashing_ray_cast)
				
			
			# BIND
			elif Input.is_action_just_pressed("bind"):
				# CANCEL BIND
				if object_to_bind == binding_ray_cast.get_collider():
					object_to_bind = null
					user_interface.set_binding_indicator(false)
					if binding_ray_cast.get_collider().being_lashed:
						binding_ray_cast.get_collider().lashings_off()
						mod_lashing_count(-1)
						currently_bound_object = null
					green_sphere.show()
					yellow_sphere.hide()
					cancel_lashing_sound.play()
					
				# TARGET BIND
				elif object_to_bind == null and binding_ray_cast.get_collider().has_method("set_target"):
					object_to_bind = binding_ray_cast.get_collider()
					user_interface.set_binding_indicator(true)
					green_sphere.hide()
					yellow_sphere.show()
					
				# ACTIVATE BIND
				elif object_to_bind != null:
					
					# binding to platform
					if binding_ray_cast.get_collider().has_method("is_platform"):
						if binding_ray_cast.get_collider().bindable:
							object_to_bind.set_target_platform(binding_ray_cast.get_collision_point(), binding_ray_cast.get_collider())
						else:
							resolve_binding = false
					# binding to objects
					elif binding_ray_cast.get_collider().has_method("is_lashable_object"):
						object_to_bind.set_target(binding_ray_cast.get_collider().global_transform.origin)
					else:
						object_to_bind.set_target(lashing_ray_cast.get_collision_point())
						
					if resolve_binding:
						if lashing_count == max_lashings:
							change_gravity_down()
							rotation_trigger = true
							if currently_bound_object != null and currently_bound_object != object_to_bind:
								currently_bound_object.lashings_off()
								currently_bound_object = null
							mod_lashing_count(-1)
							
						mod_lashing_count(1)
						currently_bound_object = object_to_bind
						object_to_bind = null
						user_interface.set_binding_indicator(false)
						green_sphere.show()
						yellow_sphere.hide()
						binding_sound.play()
					else:
						resolve_binding = true
						
					
	if not dead and not frozen and Input.is_action_just_pressed("left click"):
		if control_ray_cast.is_colliding():
			control_clicked.emit(control_ray_cast.get_collider())
				
				
	if not dead and not frozen and Input.is_action_just_released("lash"):
		rotation_trigger = true
				
	# Handle light
	#if not dead and not frozen and Input.is_action_just_pressed("flashlight"):
	#	if light_on:
	#		flashlight.visible = false
	#		light_on = false
	#	else:
	#		flashlight.visible = true
	#		light_on = true
			
	# handle tab
	if not dead and not frozen and Input.is_action_just_pressed("tab"):
		lashing_mode += 1
		if lashing_mode > max_lashing_mode_num:
			lashing_mode = 1
		user_interface.set_lashing_num(lashing_mode)
		
	# handle crouch
	if Input.is_action_just_pressed("crouch"):
		if not crouching:
			enable_crouching()
		else:
			disable_crouching()
			
	# handle action key
	if not dead and not frozen and Input.is_action_just_pressed("action"):
		action_key_pressed.emit()
		

				
	update_rotation()
	
	transform = transform.orthonormalized()
	camera_3d.transform = camera_3d.transform.orthonormalized()
	move_and_slide()


func _on_exit_game_button_pressed():
	pass # Replace with function body.


func _on_death_detection_area_entered(area):
	player_killed.emit()
	print("your dead")
	dead = true
