extends Node

var NAME_OF_DUNGEON
var DESCRIPTION
var LEVEL_DATA
var LEVEL_NUM

func _init(
	name_of_dungeon: String,
	description: String,
	level_tile_maps: Array,
):
	NAME_OF_DUNGEON = name_of_dungeon
	DESCRIPTION = description
	LEVEL_DATA = structure_tile_maps(level_tile_maps)
	LEVEL_NUM = len(LEVEL_DATA)
	
	
func save(save_name: String, file_path: String):
	
	var a = "user://"+file_path+save_name+"/"
	var b = a+"levels/"
	
	var config = {
		"name": NAME_OF_DUNGEON,
		"description": DESCRIPTION,
		"save_name": save_name,
		"level_num": LEVEL_NUM,
	}
	
	DirAccess.make_dir_absolute(a)
	DirAccess.make_dir_absolute(b)
	
	var file = FileAccess.open(a+"config.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(config))
	file.flush() # save
	
	for level in LEVEL_DATA:
		file = FileAccess.open(b+"level_"+str(level["num"]), FileAccess.WRITE)
		file.store_string(JSON.stringify(level))
		file.flush() # save
	
	
	
func structure_tile_maps(tile_maps: Array):
	var a = 0
	
	for level in tile_maps:
		level["num"] = a
		a += 1
		
	return tile_maps
	
	

