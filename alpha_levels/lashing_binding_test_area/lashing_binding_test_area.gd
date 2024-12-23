extends Node3D

@onready var platform_2 = $Platform2

# Called when the node enters the scene tree for the first time.
func _ready():
	platform_2.glide_in_loop([Vector3(-6.362, 8.705, -15.221), Vector3(-6.362, 8.705, 13.208)], 0.1, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
