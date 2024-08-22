extends RigidBody3D


var speed: float = 0.1
var target = Vector3(0, 0, 0)
var target_dir
var attraction_force_speed = 50
var time_delta: float

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var being_lashed = false

func look_follow(state: PhysicsDirectBodyState3D, current_transform: Transform3D, target_position: Vector3) -> void:
	var forward_local_axis = Vector3(1, 0, 0)
	var forward_dir = (current_transform.basis * forward_local_axis).normalized()
	target_dir = (target_position - current_transform.origin).normalized()
	#target = target_dir
	var local_speed = clampf(speed, 0, acos(forward_dir.dot(target_dir)))
	#if forward_dir.dot(target_dir) > 1e-4:
	#	state.angular_velocity = local_speed * forward_dir.cross(target_dir) / state.step
		
func set_target(new_target: Vector3):
	target = new_target
	being_lashed = true
	print(target)

func _integrate_forces(state):
	look_follow(state, global_transform, target)
	# normal gravity
	
	#if not being_lashed:
	#	linear_velocity.y -= gravity * time_delta

func _physics_process(delta):
	time_delta = delta
	if being_lashed:
		print(target)
		apply_force((target_dir * attraction_force_speed).normalized())
		gravity_scale = 0
	else:
		gravity_scale = 1
