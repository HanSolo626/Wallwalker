extends GridMap

const TORCH = preload("res://resources/map_tiles/torch/torch.tscn")
const WINDOW = preload("res://resources/map_tiles/window/window.tscn")

func is_grid_map():
	pass
	
func _ready():
	# Add torches
	var torches = get_used_cells_by_item(0)
	for torch in torches:
		var pos = to_global(map_to_local(torch))
		var torch_y_rotation = get_cell_item_orientation(torch)
		if torch_y_rotation == 22:
			torch_y_rotation = 270
		elif torch_y_rotation == 16:
			torch_y_rotation = 90
		elif torch_y_rotation == 10:
			torch_y_rotation = 180
		
		var new_torch = TORCH.instantiate()
		new_torch.rotate_y(deg_to_rad(torch_y_rotation))
		new_torch.transform.origin = pos
		add_child(new_torch)
	for torch in torches:
		set_cell_item(torch, -1)
		
	# Add windows
	# get window manager
	var manager = $"../WindowManager"
	var windows = get_used_cells_by_item(1)
	for window in windows:
		var pos = to_global(map_to_local(window))
		var window_y_rotation = get_cell_item_orientation(window)
		print(window_y_rotation)
		if window_y_rotation == 22:
			window_y_rotation = 270
		elif window_y_rotation == 16:
			window_y_rotation = 90
		elif window_y_rotation == 10:
			window_y_rotation = 180
		
		var new_window = WINDOW.instantiate()
		new_window.rotate_y(deg_to_rad(window_y_rotation))
		new_window.transform.origin = pos
		manager.add_child(new_window)
	for window in windows:
		set_cell_item(window, -1)
