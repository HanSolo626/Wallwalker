extends Node3D

@onready var platform_3 = $Platform3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_control_clicked(control_panel):
	if control_panel.player_present:
		platform_3.glide_to_position(Vector3(-5.144, 0.7, 0.211), 0.1)
