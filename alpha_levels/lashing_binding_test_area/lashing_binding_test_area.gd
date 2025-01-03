extends Node3D

@onready var platform_2 = $Platform2
@onready var control = $Control
@onready var floor_switch = $FloorSwitch
@onready var wooden_lever = $WoodenLever

func load_and_play_track():
	var track = preload("res://resources/tracks/Protoss2.mp3")
	var player = AudioStreamPlayer.new()
	player.stream = track
	player.autoplay = true
	player.volume_db = -10
	add_child(player)
	
func end_game():
	control.get_victory_menu().process_mode = PROCESS_MODE_ALWAYS
	#control.get_pause_menu().set_mouse_filter(2)
	control.get_pause_menu().process_mode = PROCESS_MODE_DISABLED
	control.get_victory_menu().activate()

# Called when the node enters the scene tree for the first time.
func _ready():
	load_and_play_track()
	platform_2.glide_in_loop(
		[Vector3(-6.362, 8.705, -15.221), Vector3(-6.362, 8.705, 13.208)], 0.1, 0
		)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if floor_switch.glowing:
		end_game()


func _on_player_player_killed():
	control.get_user_interface().enable_death_screen()


func _on_control_death_animation_done():
	get_tree().reload_current_scene()


func _on_player_action_key_pressed():
	if wooden_lever.lever_usable():
		wooden_lever.set_lever_on()
		#wooden_lever.set_disabled()
		platform_2.glide_to_position(Vector3(0, 10, 0), 0.1)
