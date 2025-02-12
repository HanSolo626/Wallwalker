extends Node3D

var multiplyer = 0.725
var target_object
var speed = 4
var returning = false

@onready var cpu_particles_3d = $CPUParticles3D

func set_target(target):
	target_object = target

# Called when the node enters the scene tree for the first time.
func _ready():
	var p = get_parent()
	var size_ref
	var t
	if p is RigidBody3D:
		for a in p.get_children():
			if a.name == "Collision":
				size_ref = a.shape.size
	if size_ref == null:
		print("ERROR! FAILED TO GET OBJECT SIZE!")
	else:
		t = size_ref.x
		if size_ref.y > t:
			t = size_ref.y
		if size_ref.z > t:
			t = size_ref.z
		t *= multiplyer
		scale.x = t
		scale.y = t
		scale.z = t
		
func _physics_process(delta):
	if target_object != null:
		var distance = get_parent().global_position - global_position
		if returning:
			distance = target_object.global_position - global_position
			transform = transform.translated(distance * speed * delta)
		else:
			transform = transform.translated(distance * speed * delta)
	if returning and global_position.is_equal_approx(target_object.global_position):
		queue_free()
