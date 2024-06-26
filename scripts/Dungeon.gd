extends GridMap


func destroy_block(world_coordinate):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, -1)
	print("Destroyed block at "+str(map_coordinate))
	
func place_block(world_coordinate, block_index):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, block_index)
	print("Placed block at "+str(map_coordinate))
	
func _ready():
	for z in range(100):
		for x in range(100):
			set_cell_item(Vector3i(x, 0, z), 0)
