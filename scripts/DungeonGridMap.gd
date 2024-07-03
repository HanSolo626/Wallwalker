extends GridMap

var current_floor = 0

var MAP_KEY = {
			"blank tile":0,
			"room tile":1,
			"corridor tile":2,
			"door tile":3,
			"wall tile":4,
			"stair tile":5,
		}

var gn = preload("res://scripts/Generator.gd").new(
	10,
	4,
	35,
	1,
	7,
	12,
	4,
	8,
	5,
	3,
	0,
	MAP_KEY
)
var dungeon = preload("res://scripts/Dungeon.gd").new("Zelda", "The_Legend_of", gn.DUNGEON)

# acts as indicator as GridMap for player script.
func is_block():
	pass
	
func get_player_start_location():
	var a = dungeon.get_level(current_floor)["start"]
	a = map_to_local(Vector3i(a[0], 1, a[1]))
	return a

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_level = dungeon.get_level(current_floor)
	
	# Make floor
	for y in range(len(current_level["tile_map"])):
		for x in range(len(current_level["tile_map"][y])):
			if current_level["tile_map"][y][x] != MAP_KEY["blank tile"]:
				set_cell_item(Vector3i(x, 0, y), 0)
	


