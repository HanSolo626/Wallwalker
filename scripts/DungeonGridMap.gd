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
	var current_level = dungeon.get_level(current_floor_num)
	
	# Make floor
	for y in range(len(current_level["tile_map"])):
		for x in range(len(current_level["tile_map"][y])):
			if current_level["tile_map"][y][x] != MAP_KEY["blank tile"]:
				set_cell_item(Vector3i(x, 0, y), block_index_num)
				
	# Make room walls
	for w in range(current_level["rh"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["wall tile"]:
					set_cell_item(Vector3i(x, w, y), block_index_num)
					
	# Make corridor walls
	for w in range(current_level["ch"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["blank tile"]:
					set_cell_item(Vector3i(x, w, y), block_index_num)
					
	# Make ceiling for corridors
	for c in range(current_level["ch"], current_level["rh"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["corridor tile"] or current_level["tile_map"][y][x] == MAP_KEY["door tile"]:
					set_cell_item(Vector3i(x, c, y), block_index_num)
					
	# Make ceiling for doors
	for c in range(current_level["dh"], current_level["rh"]):
		for y in range(len(current_level["tile_map"])):
			for x in range(len(current_level["tile_map"])):
				if current_level["tile_map"][y][x] == MAP_KEY["door tile"]:
					set_cell_item(Vector3i(x, c, y), block_index_num)
					
	# Make ceiling for rooms
	for y in range(len(current_level["tile_map"])):
		for x in range(len(current_level["tile_map"])):
			if current_level["tile_map"][y][x] == MAP_KEY["room tile"]:
				set_cell_item(Vector3i(x, current_level["rh"], y), block_index_num)
				
				
	# Add doors
	var door_num = 0
	for door in current_level["door_data"]:
		var new_d = sliding_door.instantiate()
		new_d.init_door(map_to_local(Vector3i(door[0][0], 2, door[0][1])), door[1])
		new_d.name = "BasicDoor"+str(door_num)
		add_child(new_d)
		door_num += 1
		
	# Add lamps
	var lamp_num = 0
	for lamp in current_level["lamp_data"]:
		var new_l = ceiling_lamp.instantiate()
		if lamp[1] == 0: # is it in a room?
			new_l.init_light(map_to_local(Vector3i(lamp[0][0], current_level["rh"]-1, lamp[0][1])))
		else:
			new_l.init_light(map_to_local(Vector3i(lamp[0][0], current_level["ch"]-1, lamp[0][1])))
		new_l.name = "CeilingLight"+str(lamp_num)
		add_child(new_l)
		ceiling_lights.append(new_l)
		lamp_num += 1
		
				

	


