extends Node3D

@onready var platform_2 = $Platform2
@onready var wooden_lever = $WoodenLever


func load_and_play_track():
	var track = preload("res://resources/tracks/Protoss2.mp3")
	var player = AudioStreamPlayer.new()
	player.stream = track
	player.autoplay = true
	add_child(player)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_and_play_track()
	platform_2.glide_in_loop([Vector3(-6.362, 8.705, -15.221), Vector3(-6.362, 8.705, 13.208)], 0.1, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_action_key_pressed():
	if wooden_lever.lever_usable():
		wooden_lever.set_lever_on()
		#wooden_lever.set_disabled()
		platform_2.glide_to_position(Vector3(0, 10, 0), 0.1)
