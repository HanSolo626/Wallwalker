extends Node3D

@onready var platform = $Platform

# Called when the node enters the scene tree for the first time.
func _ready():
	platform.glide_in_loop([Vector3(1, 10, 1), Vector3(1, 3, 1)], 0.1, 0.5)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
