extends MeshInstance3D

@onready var detect_player = $Door/DetectPlayer

func check_for_movement():
	if detect_player.is_colliding():
		pass
