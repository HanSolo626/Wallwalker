extends GridMap

const TORCH = preload("res://resources/map_tiles/torch/torch.tscn")

func is_grid_map():
	pass
	
func _ready():
	var torches = get_used_cells_by_item(0)
	for torch in torches:
		var pos = to_global(map_to_local(torch))
		var torch_y_rotation = deg_to_rad(90 * get_cell_item_orientation(torch))
		var new_torch = TORCH.instantiate()
		new_torch.rotate_y(torch_y_rotation)
		new_torch.transform.origin = pos
		add_child(new_torch)
	for torch in torches:
		set_cell_item(torch, -1)
