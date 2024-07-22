extends Control

@onready var dungeon_grid_map = $"../DungeonGridMap"
@onready var cheat_bar = $CheatBarBox/CheatBar
@onready var cheat_status = $CheatStatusBox/CheatStatus
@onready var player = %Player
var menu_open = false
var displayed_text = ""

var CHEAT_CODES
var CHEATS
var enabled_cheats = []

func _ready():
	CHEAT_CODES = [
		"lumosnox"
	]
	CHEATS = {
		# code    function,     				counter function,    		   cheat name
		"lumosnox": [dungeon_grid_map.flip_lights, dungeon_grid_map.flip_lights, "Lights Flipped"]
	}

func _process(_delta):
	
	if Input.is_action_just_pressed("text_input"):
		if not menu_open:
			player.freeze_player()
			cheat_bar.show()
			cheat_bar.grab_focus()
			menu_open = true
			
	if Input.is_action_just_pressed("quit") and menu_open:
		player.freeze_player() # that is, unfreeze
		cheat_bar.hide()
		cheat_bar.clear()
		menu_open = false


func _on_cheat_bar_text_submitted(new_text):
	var input = new_text
	if input in CHEAT_CODES:
		if input in enabled_cheats:
			enabled_cheats.erase(input)
			CHEATS[input][1].call()
		else:
			enabled_cheats.append(input)
			CHEATS[input][0].call()
	else:
		print("Unknown code")
		
	player.freeze_player() # that is, unfreeze
	cheat_bar.hide()
	cheat_bar.clear()
	menu_open = false
	
	if enabled_cheats.is_empty():
		displayed_text = ""
	else:
		displayed_text = "CHEATS:\n"
		for cheat in enabled_cheats:
			displayed_text = displayed_text+CHEATS[cheat][2]+"\n"
	cheat_status.text = displayed_text
	
	
	
	
