extends Node3D

@onready var platform = $Platform

# Called when the node enters the scene tree for the first time.
func _ready():
	platform.glide_to_position(Vector3(1, 1, 1), 0.1, 2)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
