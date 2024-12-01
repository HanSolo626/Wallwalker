extends Node3D

var switch1 = false

@onready var platform = $Platform
@onready var user_interface = $Control/UserInterface
@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready():
	#platform.glide_in_loop([Vector3(0, 5, 0), Vector3(-8, 5, 0), Vector3(-8, 5, -8), Vector3(0, 5, -8)], 0.1, 0.5)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func perform_action_one_test():
	platform.glide_to_position(Vector3(0, 12, 0), 0.1)


func _on_player_player_killed():
	user_interface.enable_death_screen()


func _on_area_switch_body_entered(body):
	player.change_gravity_up()
	player.rotation_trigger = true
	print("test")
	pass


func _on_player_control_clicked(control_panel):
	if control_panel.player_present:
		perform_action_one_test()
