extends Node


var POINT1
var POINT2
var TILE_MAP_REF
var MAP_KEY

var STARTING_POINT
var END_POINT
var STARTING_DIRECTION
var ENDING_DIRECTION
var START_DIR
var END_DIR
var START_POINT_OFFSET
var END_POINT_OFFSET
var LINE
var BOX
var THICKNESS
var MID_POINTS
var AREA_POINTS

var random
var Room = preload("res://scripts/Room.gd")


func _init(
	point1: Array,
	point2: Array,
	thickness: int,
	mid_points: Array,
	tile_map_ref: Array,
	map_key: Dictionary
	):
		
	var a = point1
	var b = point2
	
	POINT1 = point1
	POINT2 = point2
	
	TILE_MAP_REF = tile_map_ref
	MAP_KEY = map_key
	THICKNESS = thickness
	
	var a_above
	var a_right
	var pzde
	
	if (a[1] - b[1]) > 0:
		a_above = false
	else:
		a_above = true
	if (a[0] - b[0]) > 0:
		a_right = true
	else:
		a_right = false
		
	# prevent zero division error
	if (b[0] - a[0]) == 0:
		pzde = 1
	else:
		pzde = b[0] - a[0]
		
		
	# KEY: 0=north 1=east 2=south 3=west
	
	if (b[1] - a[1]) / pzde > 1: # more horizontal?
		if a_above:
			if a_right:
				init_wall_points(2, 1, a_above)
			else:
				init_wall_points(2, 0, a_above)
		else:
			if a_right:
				init_wall_points(0, 1, a_above)
			else:
				init_wall_points(0, 2, a_above)
	else:
		if a_right:
			if a_above:
				init_wall_points(2, 0, a_above)
			else:
				init_wall_points(3, 2, a_above)
		else:
			if a_above:
				init_wall_points(1, 0, a_above)
			else:
				init_wall_points(1, 2, a_above)
				
	# add midpoint at midpoint of rooms
	# ignore given midpoint list
	if mid_points != []:
		print("Ignoring given midpoints")
		
	mid_points = []
	var mid = [int((END_POINT[0] + STARTING_POINT[0]) / 2), int((END_POINT[1] + STARTING_POINT[1]) / 2)]
	mid_points.append(
		[int((mid[0] + STARTING_POINT[0]) / 2), int((mid[1] + STARTING_POINT[1]) / 2)]
	)
	mid_points.append(
		[int((mid[0] + END_POINT[0]) / 2), int((mid[1] + END_POINT[1]) / 2)]
	)
	MID_POINTS = mid_points
	THICKNESS = thickness
	
	# Plot area of corridor
	AREA_POINTS = plot_corridor(
		STARTING_POINT,
		END_POINT,
		STARTING_DIRECTION,
		ENDING_DIRECTION,
		THICKNESS,
		MID_POINTS
	)
	
	# Get imaginary box.
	BOX = compute_imaginary_box()
	


func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

func init_wall_points(start_dir: int, end_dir: int, a_above: bool):
	
	if a_above:
			
		STARTING_POINT = POINT1
		END_POINT = POINT2
		STARTING_DIRECTION = start_dir
		ENDING_DIRECTION = end_dir
	else:
			
		END_POINT = POINT1
		STARTING_POINT = POINT2
		ENDING_DIRECTION = start_dir
		STARTING_DIRECTION = end_dir
	
	
	
func add_to_tuple(tuple_v: Array, index: int, num: int):
	tuple_v[index] += num
	return tuple_v
	

func plot_corridor(
	start: Array,
	end: Array,
	starting_direction: int,
	ending_direction: int,
	thickness: int,
	midpoints: Array
	):
		
	var area_points = []
	var org_end = end
	var org_start = start
	
	var h = floor(thickness / 2)
	var why = ceil(thickness / 2)
	
	# ensure thickness is odd
	if thickness % 2 == 0:
		thickness -= 1
		
	# Offset start and end coordinates
	if starting_direction == 0: # North
		start = add_to_tuple(start, 1, -why)
	elif starting_direction == 1: # East
		start = add_to_tuple(start, 0, why)
	elif starting_direction == 2: # South
		start = add_to_tuple(start, 1, why)
	elif starting_direction == 3: # West
		start = add_to_tuple(start, 0, -why)
		
	if ending_direction == 0: # North
		end = add_to_tuple(end, 1, -why)
	elif ending_direction == 1: # East
		end = add_to_tuple(end, 0, why)
	elif ending_direction == 2: # South
		end = add_to_tuple(end, 1, why)
	elif ending_direction == 3: # West
		end = add_to_tuple(end, 0, -why)
		
	START_POINT_OFFSET = start
	END_POINT_OFFSET = end
	
	# Prep list
	var points = []
	points.append(start)
	for thing in midpoints:
		points.append(thing)
	points.append(end)
	
	area_points.append(start)
	
	for x in range(len(points) - 1):
		var one = points[x]
		var two = points[x + 1]
		var current_x = one[0]
		var current_y = one[1]
		
		# Get slope from one to two.
		var slope1 = [two[0] - one[0], two[1] - one[1]]
		
		# Decide based on direction
		var chance
		if x == 0:
			if starting_direction == 0 or starting_direction == 2:
				chance = 0
			elif starting_direction == 1 or starting_direction == 3:
				chance = 1
		elif x == len(points) - 2:
			if ending_direction == 0 or ending_direction == 2:
				chance = 1
			elif ending_direction == 1 or ending_direction == 3:
				chance = 0
		else:
			chance = random.randi(0, 1) # Decide to do X, then Y, or Y, then X.
			
		var a
		if chance == 0:
			if slope1[0] < 0:
				a = -1
			else:
				a = 1
				
			for t in range(0, slope1[0], a): # X
				current_x = current_x + a
				area_points.append([current_x, current_y])
				
			if slope1[1] < 0:
				a = -1
			else:
				a = 1
				
			for t in range(0, slope1[1], a): # Y
				current_y = current_y + a
				area_points.append([current_x, current_y])
		else:
			if slope1[1] < 0:
				a = -1
			else:
				a = 1
				
			for t in range(0, slope1[1], a): # Y
				current_y = current_y + a
				area_points.append([current_x, current_y])
				
			if slope1[0] < 0:
				a = -1
			else:
				a = 1
				
			for t in range(0, slope1[0], a): # X
				current_x = current_x + a
				area_points.append([current_x, current_y])
				
	LINE = area_points.duplicate(true)
	
	# Now that the line is plotted, thickness can be added
	var updated_area_points = []
	for point in area_points:
		point = [point[0] - h, point[1] - h]
		for y in range(point[1], point[1] + thickness):
			for x in range(point[0], point[0] + thickness):
				if [x, y] not in updated_area_points:
					updated_area_points.append([x, y])
					
	# Shave off the first and last row/column
	
	updated_area_points.erase([org_start[0], org_start[1]])
	updated_area_points.erase([org_end[0], org_end[1]])
	
	if starting_direction == 0 or starting_direction == 2:
		
		for x in range(org_start[0] - h, org_start[0] + h + 1):
			updated_area_points.erase([x, org_start[1]])
			
		for x in range(org_end[0] - h, org_end[0] + h + 1):
			updated_area_points.erase([x, org_end[1]])
			
	else:
		
		for x in range(org_start[1] - h, org_start[1] + h + 1):
			updated_area_points.erase([org_start[0], x])
			
		for x in range(org_end[1], org_end[1] + h + 1):
			updated_area_points.erase([org_end[0], x])
			
	
	area_points = updated_area_points.duplicate(true)
	
	# Check if colliding with room
	for point in area_points:
		if TILE_MAP_REF[point[1]][point[0]] == MAP_KEY["room tile"] or TILE_MAP_REF[point[1]][point[0]] == MAP_KEY["wall tile"]:
			return []
	
	
	return area_points
	

func compute_imaginary_box():
	
	var area = []
	var h = floor(THICKNESS / 2)
	var start_corner = STARTING_POINT.duplicate(true)
	var end_corner = END_POINT.duplicate(true)
	
	# Refering to start point
	var ything
	var xthing
	var a
	var b
	var c
	var d
	
	if END_POINT_OFFSET[0] - START_POINT_OFFSET[0] < 0: # end to the left?
		ything = -1
	else:
		ything = 1
		
	if END_POINT_OFFSET[1] - START_POINT_OFFSET[1] < 0: # end above?
		xthing = -1
	else:
		xthing = 1
		
	if STARTING_DIRECTION == 0 or STARTING_DIRECTION == 2:
		if xthing == -1:
			start_corner[0] += h
		else:
			start_corner[0] -= h
			
	else:
		if ything == -1:
			start_corner[1] += h
		else:
			start_corner[1] -= h
			
	# Invert things
	xthing = -xthing
	ything = -ything
	
	if ENDING_DIRECTION == 0 or ENDING_DIRECTION == 2:
		if xthing == -1:
			end_corner[0] += h
		else:
			end_corner[0] -= h
	else:
		if ything == -1:
			end_corner[1] += h
		else:
			end_corner[1] -= h
			
	if ything == 1:
		a = end_corner[1]
		b = start_corner[1]
	else:
		a = start_corner[1]
		b = end_corner[1]
	if xthing == 1:
		c = end_corner[0]
		d = start_corner[0]
	else:
		c = start_corner[0]
		d = end_corner[0]
		
	for y in range(a, b+1):
		for x in range(c+1, d):
			area.append([x, y])
			
	return area
			
			
	
	
	
	
	
	
	
	
	
	
	
	
	

