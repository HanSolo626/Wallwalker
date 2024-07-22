extends Node


var ROOM1
var ROOM2
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

var START_DOOR
var START_DOOR_POINTS
var START_DOOR_VERTICAL
var END_DOOR
var END_DOOR_POINTS
var END_DOOR_VERTICAL
var door_radius = 1

var random
var Room = preload("res://scripts/Room.gd")

var LAMPS




func _init(
	room1,
	room2,
	thickness: int,
	mid_points: Array,
	tile_map_ref: Array,
	map_key: Dictionary
	):
		
	var a = room1.POSITION
	var b = room2.POSITION
	
	ROOM1 = room1
	ROOM2 = room2
	
	TILE_MAP_REF = tile_map_ref
	MAP_KEY = map_key
	THICKNESS = thickness
	LAMPS = []
	
	random = RandomNumberGenerator.new()
	random.randomize()
	
	var a_above
	var a_right
	
	if (a[1] - b[1]) > 0:
		a_above = false
	else:
		a_above = true
	if (a[0] - b[0]) > 0:
		a_right = true
	else:
		a_right = false
		
	# account for room size
	if a_right:
		a = [a[0] + len(room1.NORTH_WALL)+2, a[1]]
		b = [b[0] - len(room2.NORTH_WALL)+2, b[1]]
	else:
		a = [a[0] - len(room1.NORTH_WALL)+2, a[1]]
		b = [b[0] + len(room2.NORTH_WALL)+2, b[1]]
		
	# NOTE irregularity here
	if a_above:
		a = [a[0], b[1] - len(room1.WEST_WALL)+2]
		b = [b[0], b[1] + len(room2.WEST_WALL)+2]
	else:
		a = [a[0], b[1] + len(room1.WEST_WALL)+2]
		b = [b[0], b[1] - len(room2.WEST_WALL)+2]
		
	# KEY: 0=north 1=east 2=south 3=west
	if a_above:
		if a_right:
			init_wall_points(rint(2, 3), rint(0, 1), a_above)
		else:
			init_wall_points(rint(1, 2), rint(0, 3), a_above)
	else:
		if a_right:
			init_wall_points(rint(0, 3), rint(1, 2), a_above)
		else:
			init_wall_points(rint(0, 1), rint(2, 3), a_above)
			
	# add midpoint at midpoint of rooms
	# ignore given midpoint list
	if mid_points != []:
		print("Ignoring given midpoints")
		
	mid_points = []
	var mid = [int((END_POINT[0] + STARTING_POINT[0]) / 2), int((END_POINT[1] + STARTING_POINT[1]) / 2)]
	mid_points.append(mid)
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
	


func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

func init_wall_points(start_dir: int, end_dir: int, a_above: bool):
	var tries = 4
	var start_count = 0
	var end_count = 0
	
	if a_above:
		
		for y in range(tries):
			# check if wall occupied
			if ROOM1.wall_status[start_dir]:
				if start_dir == 3:
					start_dir = 0
				else:
					start_dir += 1
				start_count += 1
				
			if ROOM2.wall_status[end_dir]:
				if end_dir == 0:
					end_dir = 3
				else:
					end_dir -= 1
				end_count += 1
				
		if start_count >= tries:
			print("All walls are taken! ROOM1 WALL STATUS: "+
			str(ROOM1.wall_status))
			get_tree().quit()
		if end_count >= tries:
			print("All walls are taken! ROOM2 WALL STATUS: "+
			str(ROOM1.wall_status))
			get_tree().quit()
			
		STARTING_POINT = ROOM1.get_random_wall_point(start_dir)
		END_POINT = ROOM2.get_random_wall_point(end_dir)
		STARTING_DIRECTION = start_dir
		ENDING_DIRECTION = end_dir
	else:
		
		for y in range(tries):
			# check if wall occupied
			if ROOM1.wall_status[start_dir]:
				if start_dir == 0:
					start_dir = 3
				else:
					start_dir -= 1
				start_count += 1
			
			if ROOM2.wall_status[end_dir]:
				if end_dir == 3:
					end_dir = 0
				else:
					end_dir += 1
				end_count += 1
				
		if start_count >= tries:
			print("All walls are taken! ROOM1 WALL STATUS: "+
			str(ROOM1.wall_status))
			get_tree().quit()
		if end_count >= tries:
			print("All walls are taken! ROOM2 WALL STATUS: "+
			str(ROOM1.wall_status))
			get_tree().quit()
			
		END_POINT = ROOM1.get_random_wall_point(start_dir)
		STARTING_POINT = ROOM2.get_random_wall_point(end_dir)
		ENDING_DIRECTION = start_dir
		STARTING_DIRECTION = end_dir
		
	START_DIR = start_dir
	END_DIR = end_dir
	
	ROOM1.wall_status[start_dir] = true
	ROOM2.wall_status[end_dir] = true
	
	
func add_to_tuple(tuple_v: Array, index: int, num: int):
	tuple_v[index] += num
	return tuple_v
	
func rint(a: int, b: int):
	if random.randi_range(0,1) == 0:
		return a
	else:
		return b
		
func get_modified_rooms():
	ROOM1.mod_num += 1
	ROOM2.mod_num += 1
	return [ROOM1, ROOM2]
	
func get_midpoint():
	return MID_POINTS[0]
	

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
	
	var h = floor(float(thickness) / 2)
	var why = ceil(float(thickness) / 2)
	
	# ensure thickness is odd
	if thickness % 2 == 0:
		thickness -= 1
		
	# Offset start and end coordinates
	if starting_direction == 0: # North
		start = add_to_tuple(start, 1, -why)
		START_DOOR = add_to_tuple(start.duplicate(), 1, h+1)
		
	elif starting_direction == 1: # East
		start = add_to_tuple(start, 0, why)
		START_DOOR = add_to_tuple(start.duplicate(), 0, h-thickness) # NOTE
		
	elif starting_direction == 2: # South
		start = add_to_tuple(start, 1, why)
		START_DOOR = add_to_tuple(start.duplicate(), 1, h-thickness)
		
	elif starting_direction == 3: # West
		start = add_to_tuple(start, 0, -why)
		START_DOOR = add_to_tuple(start.duplicate(), 0, h+1)
		
		
	if ending_direction == 0: # North
		end = add_to_tuple(end, 1, -why)
		END_DOOR = add_to_tuple(end.duplicate(), 1, h+1)
		
	elif ending_direction == 1: # East
		end = add_to_tuple(end, 0, why)
		END_DOOR = add_to_tuple(end.duplicate(), 0, h-thickness)
		
	elif ending_direction == 2: # South
		end = add_to_tuple(end, 1, why)
		END_DOOR = add_to_tuple(end.duplicate(), 1, h+1)
		
	elif ending_direction == 3: # West
		end = add_to_tuple(end, 0, -why)
		END_DOOR = add_to_tuple(end.duplicate(), 0, h+1)
		
	# Get door area points
	START_DOOR_POINTS = []
	END_DOOR_POINTS = []
	if starting_direction == 0 or starting_direction == 2:
		START_DOOR_VERTICAL = true
		for x in range(START_DOOR[0]-door_radius, START_DOOR[0]+door_radius+1):
			START_DOOR_POINTS.append([x, START_DOOR[1]])
			
	elif starting_direction == 1 or starting_direction == 3:
		START_DOOR_VERTICAL = false
		for y in range(START_DOOR[1]-door_radius, START_DOOR[1]+door_radius+1):
			START_DOOR_POINTS.append([START_DOOR[0], y])
			
	if ending_direction == 0 or ending_direction == 2:
		END_DOOR_VERTICAL = true
		for x in range(END_DOOR[0]-door_radius, END_DOOR[0]+door_radius+1):
			END_DOOR_POINTS.append([x, END_DOOR[1]])
			
	elif ending_direction == 1 or ending_direction == 3:
		END_DOOR_VERTICAL = false
		for y in range(END_DOOR[1]-door_radius, END_DOOR[1]+door_radius+1):
			END_DOOR_POINTS.append([END_DOOR[0], y])
		
	START_POINT_OFFSET = start
	END_POINT_OFFSET = end
	
	# Prep list
	var points = []
	points.append(start)
	for thing in midpoints:
		points.append(thing)
	points.append(end)
	
	# Get lamps
	LAMPS = points
	
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
			chance = random.randi_range(0, 1) # Decide to do X, then Y, or Y, then X.
			
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
				
					
	## Shave off the first and last row/column
	#
	#updated_area_points.erase([org_start[0], org_start[1]])
	#updated_area_points.erase([org_end[0], org_end[1]])
	#
	#if starting_direction == 0 or starting_direction == 2:
	#	
	#	for x in range(org_start[0] - h, org_start[0] + h + 1):
	#		updated_area_points.erase([x, org_start[1]])
	#		
	#	for x in range(org_end[0] - h, org_end[0] + h + 1):
	#		updated_area_points.erase([x, org_end[1]])
	#		
	#else:
	#	
	#	for x in range(org_start[1] - h, org_start[1] + h + 1):
	#		updated_area_points.erase([org_start[0], x])
	#		
	#	for x in range(org_end[1], org_end[1] + h + 1):
	#		updated_area_points.erase([org_end[0], x])
			
	
	area_points = updated_area_points.duplicate(true)
	
	# Check if colliding with room
	for point in area_points:
		if TILE_MAP_REF[point[1]][point[0]] == MAP_KEY["room tile"] or TILE_MAP_REF[point[1]][point[0]] == MAP_KEY["wall tile"]:
			ROOM1.wall_status[START_DIR] = false
			ROOM2.wall_status[END_DIR] = false
			STARTING_POINT = null
			END_POINT = null
			return []
			
	# Get imaginary box.
	BOX = compute_imaginary_box()
	
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
			
