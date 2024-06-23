extends CharacterBody3D


const SPEED = 8.0
const JUMP_VELOCITY = 12
# the smaller this value, the faster it goes
const CAMERA_ROTATION_SPEED = 50

# Get the gravity from the project settings to be synced with RigidBody nodes. (nope!)
var gravity = 24.0
var sensitivity = 0.002
var current_pull = 1
var positive = true
var dir_str = "ceiling"

var x_to_set = 0.0
var y_to_set = 0.0
var z_to_set = 0.0
var x_updates = 0
var y_updates = 0
var z_updates = 0


# Camera angle data
const CAMERA_ANGLES = {
	"floor":{
		"up":[180, null, 0],
		"down":null,
		"left":[null, null, -90],
		"right":[null, null, 90],
		"forward":[-90, null, null],
		"backward":[90, null, null]
	},
	"ceiling":{
		"up":null,
		"down":[0, null, null],
		"left":[null, null, -90],
		"right":[null, null, 90],
		"forward":[90, null, null],
		"backward":[-90, null, null]
	},
	"left wall":{
		"up":[],
		"down":[],
		"left":null,
		"right":[],
		"forward":[],
		"backward":[]
	},
	"right wall":{
		"up":[],
		"down":[],
		"left":[],
		"right":null,
		"forward":[],
		"backward":[]
	},
	"forward wall":{
		"up":[],
		"down":[],
		"left":[],
		"right":[],
		"forward":null,
		"backward":[]
	},
	"backward wall":{
		"up":[],
		"down":[],
		"left":[],
		"right":[],
		"forward":[],
		"backward":null
	},
}



@onready var camera_3d = $Camera3D
@onready var ray_cast_3d = $Camera3D/RayCast3D
@onready var gridmap = preload("res://scripts/GridMap.gd").new()
@onready var collision_shape_3d = $CollisionShape3D
@onready var body = $Body
@onready var stick = $stick


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
	if y_updates > 0:
		rotate_y(y_to_set)
		y_updates -= 1
		
	if x_updates > 0:
		rotate_x(x_to_set)
		x_updates -= 1
		
	if z_updates > 0:
		rotate_z(z_to_set)
		z_updates -= 1
	


func change_rotation(data):
	# get difference
	#set_top_level(true)
	#transform.basis = Basis()
	#set_top_level(false)
	var x = data[0]
	var y = data[1]
	var z = data[2]
	

	if x == null:
		pass
	else:
		if x == 0:
			if rotation.z < 0:
				x_to_set = rotation.z / CAMERA_ROTATION_SPEED
			else: 
				x_to_set = -rotation.z / CAMERA_ROTATION_SPEED
		else:
			x_to_set = (deg_to_rad(abs(x)) - rotation.x) * (x / abs(x)) / CAMERA_ROTATION_SPEED
		x_updates = CAMERA_ROTATION_SPEED
	
	if y == null:
		pass
	else:
		if y == 0:
			if rotation.y < 0:
				y_to_set = rotation.y / CAMERA_ROTATION_SPEED
			else:
				y_to_set = -rotation.y / CAMERA_ROTATION_SPEED
		else:
			y_to_set = (deg_to_rad(abs(y)) - rotation.y) * (y / abs(y)) / CAMERA_ROTATION_SPEED
		y_updates = CAMERA_ROTATION_SPEED
	
	if z == null:
		pass
	else:
		if z == 0:
			if rotation.z < 0:
				z_to_set = rotation.z / CAMERA_ROTATION_SPEED
			else:
				z_to_set = -rotation.z / CAMERA_ROTATION_SPEED
		else:
			z_to_set = (deg_to_rad(abs(z)) - rotation.z) * (z / abs(z)) / CAMERA_ROTATION_SPEED
		z_updates = CAMERA_ROTATION_SPEED
		
		
	
	print("X: "+str(x_to_set)+" Y: "+str(y_to_set)+" Z: "+str(z_to_set))
	


func change_gravity(raycast_object):
	# get points
	var block = raycast_object.get_collision_point() - raycast_object.get_collision_normal()
	var face = raycast_object.get_collision_point() + raycast_object.get_collision_normal()
	
	# convert to integers
	block = gridmap.local_to_map(block)
	face = gridmap.local_to_map(face)
	
	# extract direction
	# x = 0
	# y = 1
	# z = 2
	if block.x - face.x < 0 and (current_pull != 0 or positive != false):
		print("left")
		current_pull = 0
		positive = false
		change_rotation(CAMERA_ANGLES[dir_str]["left"])
		dir_str = "left wall"
		
	elif block.x - face.x > 0 and (current_pull != 0 or positive != true):
		print("right")
		current_pull = 0
		positive = true
		change_rotation(CAMERA_ANGLES[dir_str]["right"])
		dir_str = "right wall"
		
	elif block.y - face.y < 0 and (current_pull != 1 or positive != false):
		print("down")
		current_pull = 1
		positive = false
		change_rotation(CAMERA_ANGLES[dir_str]["down"])
		dir_str = "floor"
		
	elif block.y - face.y > 0 and (current_pull != 1 or positive != true):
		print("up")
		current_pull = 1
		positive = true
		change_rotation(CAMERA_ANGLES[dir_str]["up"])
		dir_str = "ceiling"
		
	elif block.z - face.z < 0 and (current_pull != 2 or positive != false):
		print("backward")
		current_pull = 2
		positive = false
		change_rotation(CAMERA_ANGLES[dir_str]["backward"])
		dir_str = "backward wall"
		
	elif block.z - face.z > 0 and (current_pull != 2 or positive != true):
		print("forward")
		current_pull = 2
		positive = true
		change_rotation(CAMERA_ANGLES[dir_str]["forward"])
		dir_str = "forward wall"
		



func _ready(): # setup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_top_level(false)
	change_rotation(CAMERA_ANGLES["floor"]["up"])
	
	
func _input(event):
	# Mouse input
	if event is InputEventMouseMotion and is_rotating() == false:
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
	
	# Check for quit
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
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
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall() or is_on_ceiling()):
		if not positive:
			if current_pull == 0: # X
				velocity.x = JUMP_VELOCITY
			elif current_pull == 1: # Y
				velocity.y = JUMP_VELOCITY
			elif current_pull == 2: # X
				velocity.z = JUMP_VELOCITY
		else:
			if current_pull == 0: # X
				velocity.x = -JUMP_VELOCITY
			elif current_pull == 1: # Y
				velocity.y = -JUMP_VELOCITY
			elif current_pull == 2: # X
				velocity.z = -JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		
	if direction:
		if current_pull == 0: # X
			velocity.y = direction.y * SPEED
			velocity.z = direction.z * SPEED
		elif current_pull == 1: # Y
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		elif current_pull == 2: # Z
			velocity.y = direction.y * SPEED
			velocity.x = direction.x * SPEED
	else:
		if current_pull == 0 and is_on_wall(): # X
			velocity.y = 0
			velocity.z = 0
		elif current_pull == 1 and (is_on_floor() or is_on_ceiling()): # Y
			velocity.x = 0
			velocity.z = 0
		elif current_pull == 2 and is_on_wall(): # Z
			velocity.y = 0
			velocity.x = 0
			
		
		
	# handle mouse clicks
	#if Input.is_action_just_pressed("right click"):
	#	if ray_cast_3d.is_colliding():
	#		if ray_cast_3d.get_collider().has_method("destroy_block"):
	#			change_gravity(ray_cast_3d)
				#ray_cast_3d.get_collider().destroy_block(ray_cast_3d.get_collision_point() - ray_cast_3d.get_collision_normal())
				
	if Input.is_action_just_pressed("left click"):
		if ray_cast_3d.is_colliding():
			if ray_cast_3d.get_collider().has_method("place_block") and not (
				is_on_ceiling() or is_on_floor() or is_on_wall()
				):
				change_gravity(ray_cast_3d)
				#ray_cast_3d.get_collider().place_block(ray_cast_3d.get_collision_point() + 
				#ray_cast_3d.get_collision_normal(), 0)
				
	update_rotation()
	
	transform = transform.orthonormalized()
	camera_3d.transform = camera_3d.transform.orthonormalized()
	move_and_slide()
