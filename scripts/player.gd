extends CharacterBody3D


# 1: Personal Gravity
# 2: Bind objects
var lashing_mode = 1

var max_lashing_mode_num = 2
var object_to_bind

const WALKING_SPEED = 8.0
const SPRINT_SPEED = 15.0
const JUMP_VELOCITY = 12
# the smaller this value, the faster it goes
const CAMERA_ROTATION_SPEED = 25
var light_on = true
var frozen = false

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


@onready var camera_3d = $Camera3D
@onready var lashing_ray_cast = $Camera3D/LashingRayCast
@onready var binding_ray_cast = $Camera3D/BindingRayCast
@onready var collision_shape_3d = $CollisionShape3D
@onready var body = $Body
@onready var stick = $stick
@onready var gridmap = $"../DungeonGridMap"
@onready var flashlight = $Camera3D/SpotLight3D
@onready var user_interface = $"../UserInterface"


func set_top_level(t):
	camera_3d.top_level = t
	collision_shape_3d.top_level = t
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
	


func change_gravity(raycast_object):
	# get points
	var block = raycast_object.get_collision_point() - raycast_object.get_collision_normal()
	var face = raycast_object.get_collision_point() + raycast_object.get_collision_normal()
	
	
	
	# extract direction
	# x = 0
	# y = 1
	# z = 2
	if block.x - face.x < 0 and (current_pull != 0 or positive != false):
		print("left")
		current_pull = 0
		positive = false
		arm_rotation_change(CAMERA_ANGLES[dir_str]["left"])
		dir_str = "left wall"
		up_direction = Vector3.RIGHT
		
		
	elif block.x - face.x > 0 and (current_pull != 0 or positive != true):
		print("right")
		current_pull = 0
		positive = true
		arm_rotation_change(CAMERA_ANGLES[dir_str]["right"])
		dir_str = "right wall"
		up_direction = Vector3.LEFT
		
		
	elif block.y - face.y < 0 and (current_pull != 1 or positive != false):
		print("down")
		current_pull = 1
		positive = false
		arm_rotation_change(CAMERA_ANGLES[dir_str]["down"])
		dir_str = "floor"
		up_direction = Vector3.UP
		
		
	elif block.y - face.y > 0 and (current_pull != 1 or positive != true):
		print("up")
		current_pull = 1
		positive = true
		arm_rotation_change(CAMERA_ANGLES[dir_str]["up"])
		dir_str = "ceiling"
		up_direction = Vector3.DOWN
		
		
	elif block.z - face.z < 0 and (current_pull != 2 or positive != false):
		print("backward")
		current_pull = 2
		positive = false
		arm_rotation_change(CAMERA_ANGLES[dir_str]["backward"])
		dir_str = "backward wall"
		up_direction = Vector3.BACK
		
		
	elif block.z - face.z > 0 and (current_pull != 2 or positive != true):
		print("forward")
		current_pull = 2
		positive = true
		arm_rotation_change(CAMERA_ANGLES[dir_str]["forward"])
		dir_str = "forward wall"
		up_direction = Vector3.FORWARD
		
		


func freeze_player():
	if frozen:
		frozen = false
	else:
		frozen = true


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
	if not frozen and Input.is_action_just_pressed("jump") and is_on_floor():
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
	
	if Input.is_action_pressed("shift_key"):
		multiplyer = SPRINT_SPEED
	else:
		multiplyer = WALKING_SPEED
		
	if not frozen and direction:
		if current_pull == 0: # X
			velocity.y = direction.y * multiplyer
			velocity.z = direction.z * multiplyer
		elif current_pull == 1: # Y
			velocity.x = direction.x * multiplyer
			velocity.z = direction.z * multiplyer
		elif current_pull == 2: # Z
			velocity.y = direction.y * multiplyer
			velocity.x = direction.x * multiplyer
	else:
		if current_pull == 0 and (is_on_floor()): # X
			velocity.y = 0
			velocity.z = 0
			rotation_trigger = true
		elif current_pull == 1 and (is_on_floor() or is_on_ceiling()): # Y
			velocity.x = 0
			velocity.z = 0
			rotation_trigger = true
		elif current_pull == 2 and (is_on_floor()): # Z
			velocity.y = 0
			velocity.x = 0
			rotation_trigger = true
			
		
		
	# handle mouse clicks
	if not frozen and Input.is_action_just_pressed("lash"):
		if lashing_ray_cast.is_colliding() or binding_ray_cast.is_colliding():
			
			if lashing_mode == 1 and (lashing_ray_cast.get_collider().has_method("is_block") or lashing_ray_cast.get_collider().has_method("is_platform")) and is_rotating() == false:
				change_gravity(lashing_ray_cast)
			elif lashing_mode == 2:
				if object_to_bind == binding_ray_cast.get_collider():
					object_to_bind = null
					user_interface.set_binding_indicator(false)
					if binding_ray_cast.get_collider().being_lashed:
						binding_ray_cast.get_collider().being_lashed = false
				elif object_to_bind == null and binding_ray_cast.get_collider().has_method("set_target"):
					object_to_bind = binding_ray_cast.get_collider()
					user_interface.set_binding_indicator(true)
				elif object_to_bind != null:
					if binding_ray_cast.get_collider().has_method("is_platform"):
						object_to_bind.set_target(binding_ray_cast.get_collider())
					else:
						object_to_bind.set_target(binding_ray_cast.get_collision_point())
					object_to_bind = null
					user_interface.set_binding_indicator(false)
				
				
	if not frozen and Input.is_action_just_released("lash"):
		rotation_trigger = true
				
	# Handle light
	if not frozen and Input.is_action_just_pressed("flashlight"):
		if light_on:
			flashlight.visible = false
			light_on = false
		else:
			flashlight.visible = true
			light_on = true
			
	# handle tab
	if not frozen and Input.is_action_just_pressed("tab"):
		lashing_mode += 1
		if lashing_mode > max_lashing_mode_num:
			lashing_mode = 1
		user_interface.set_lashing_num(lashing_mode)

				
	update_rotation()
	
	transform = transform.orthonormalized()
	camera_3d.transform = camera_3d.transform.orthonormalized()
	move_and_slide()


func _on_exit_game_button_pressed():
	pass # Replace with function body.
