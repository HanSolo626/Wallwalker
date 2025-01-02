extends Node3D

var multiplyer = 0.725

@onready var cpu_particles_3d = $CPUParticles3D

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
