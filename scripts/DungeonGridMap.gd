extends GridMap

var current_floor_num = 0
var block_index_num = 3

var MAP_KEY = {
			"blank tile":0,
			"room tile":1,
			"corridor tile":2,
			"door tile":3,
			"wall tile":4,
			"stair tile":5,
		}

var gn = preload("res://scripts/Generator.gd").new(
	1,
	4,
	50,
	1,
	17,
	27,
	5,
	8,
	4,
	5,
	5,
	0,
	MAP_KEY
)


var dungeon = preload("res://scripts/Dungeon.gd").new("Zelda", "The_Legend_of", gn.DUNGEON)
@export var sliding_door: PackedScene
@export var ceiling_lamp: PackedScene
var ceiling_lights = []

# acts as indicator as GridMap for player script.
func is_block():
	pass
	
func get_player_start_location():
	var a = dungeon.get_level(current_floor_num)["start"]
	a = map_to_local(Vector3i(a[0], 2, a[1]))
	return a
	
func flip_lights():
	for light in ceiling_lights:
		light.flip_light()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
		
				

	


