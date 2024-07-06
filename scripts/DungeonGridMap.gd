extends GridMap

var current_floor_num = 0

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
	50,
	3,
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

# acts as indicator as GridMap for player script.
func is_block():
	pass
	
func get_player_start_location():
	var a = dungeon.get_level(current_floor_num)["start"]
	a = map_to_local(Vector3i(a[0], 1, a[1]))
	return a

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_level = dungeon.get_level(current_floor_num)
	
	# Make floor
	for y in range(len(current_level["tile_map"])):
		for x in range(len(current_level["tile_map"][y])):
			if current_level["tile_map"][y][x] != MAP_KEY["blank tile"]:
				set_cell_item(Vector3i(x, 0, y), 0)
			#elif current_level["tile_map"][y][x] == MAP_KEY["room tile"]:
			#	set_cell_item(Vector3i(x, 0, y), 1)
			#elif current_level["tile_map"][y][x] == MAP_KEY["corridor tile"]:
			#	set_cell_item(Vector3i(x, 0, y), 2)
			#elif current_level["tile_map"][y][x] == MAP_KEY["door tile"]:
			#	set_cell_item(Vector3i(x, 0, y), 3)
			#elif current_level["tile_map"][y][x] == MAP_KEY["wall tile"]:
			#	set_cell_item(Vector3i(x, 0, y), 4)
			#elif current_level["tile_map"][y][x] == MAP_KEY["stair tile"]:
			#	set_cell_item(Vector3i(x, 0, y), 0)
				
	# Make room walls
	for w in range(current_level["rh"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["wall tile"]:
					set_cell_item(Vector3i(x, w, y), 0)
					
	# Make corridor walls
	for w in range(current_level["ch"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["blank tile"]:
					set_cell_item(Vector3i(x, w, y), 0)
					
	# Make ceiling for corridors
	for c in range(current_level["ch"], current_level["rh"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["corridor tile"] or current_level["tile_map"][y][x] == MAP_KEY["door tile"]:
					set_cell_item(Vector3i(x, c, y), 0)
					
	# Make ceiling for doors
	for c in range(current_level["dh"], current_level["rh"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["door tile"]:
					set_cell_item(Vector3i(x, c, y), 0)
					
	# Make ceiling for rooms
	for y in range(len(current_level["tile_map"])):
		for x in range(len(current_level["tile_map"])):
			if current_level["tile_map"][y][x] == MAP_KEY["room tile"]:
				set_cell_item(Vector3i(x, current_level["rh"], y), 0)
				

	


