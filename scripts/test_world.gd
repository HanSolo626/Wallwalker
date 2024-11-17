extends Node3D

@onready var platform = $Platform
@onready var user_interface = $Control/UserInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	platform.glide_in_loop([Vector3(0, 5, 0), Vector3(-8, 5, 0), Vector3(-8, 5, -8), Vector3(0, 5, -8)], 0.1, 0.5)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_player_killed():
	user_interface.enable_death_screen()
