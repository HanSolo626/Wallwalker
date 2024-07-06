extends Node


var POSITION
var STAIRWELL
var SIZE_X
var SIZE_Y
var CFS
var AREA_POINTS
var CORNER_POINTS
var NORTH_WALL
var EAST_WALL
var SOUTH_WALL
var WEST_WALL
var walls
var WALL_AREA_POINTS
var wall_status
var STAIRWELL_AREA_POINTS
var mod_num = 0

var random

func _init(
	position: Array,
	size_x,
	size_y,
	stairwell
):
	
	POSITION = position
	STAIRWELL = stairwell
	SIZE_X = check_x_input(size_x)
	SIZE_Y = check_y_input(size_y)
	CFS = 4
	
	random = RandomNumberGenerator.new()
	random.randomize()
	
	if position[0] < 0 or position[1] < 0:
		print("ERROR: Position of X, Y coordinates cannot be negative.")
		get_tree().quit()
	
	# Get points that room occupies.
	AREA_POINTS = get_area_points(POSITION, SIZE_X, SIZE_Y)
	CORNER_POINTS = get_corners(POSITION, SIZE_X, SIZE_Y)
	
	NORTH_WALL = get_wall_points(0, CORNER_POINTS)
	EAST_WALL = get_wall_points(1, CORNER_POINTS)
	SOUTH_WALL = get_wall_points(2, CORNER_POINTS)
	WEST_WALL = get_wall_points(3, CORNER_POINTS)
	
	walls = [
		NORTH_WALL.duplicate(true),
		EAST_WALL.duplicate(true),
		SOUTH_WALL.duplicate(true),
		WEST_WALL.duplicate(true),
	]
	
	WALL_AREA_POINTS = get_wall_area()
	
	# Corridor there?
	wall_status = [false, false, false, false]
	
	# stairwell_up = 2, stairwell_down = 1
	if STAIRWELL == 2  or STAIRWELL == 1:
		STAIRWELL_AREA_POINTS = get_stair_area()
	else:
		STAIRWELL_AREA_POINTS = []
	

func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()
	
	
func get_stair_area():
	var points = []
	var center = POSITION
	var rad = 1
	for y in range(center[1] - rad, center[1] + rad +1):
		for x in range(center[0] - rad, center[0] + rad +1):
			points.append([x, y])
	return points.duplicate(true)
	
	
func get_wall_area():
	var w = []
	for point in CORNER_POINTS:
		w.append(point)
	for point in NORTH_WALL:
		w.append(point)
	for point in EAST_WALL:
		w.append(point)
	for point in SOUTH_WALL:
		w.append(point)
	for point in WEST_WALL:
		w.append(point)
	return w.duplicate(true)
	
	
func get_random_wall_point(wall_num):
	# Keep corridor thickness in mind when setting this
	var limit = 2
	wall_status[wall_num] = true
	var door = walls[wall_num][random.randi_range(1, len(walls[wall_num]) - limit )]
	return door
	

func get_area_points(position, size_x, size_y):
	var area_points = []
	
	var a = floor(size_x / 2)
	var b = floor(size_y / 2)
	
	for r in range(size_y):
		for c in range(size_x):
			area_points.append([position[0] - a + c, position[1] - b + r])
			
	# Check for negative points.
	for point in area_points:
		if point[0] < 0 or point[1] < 0:
			print("ERROR: Negative area point! Position is probably too close to edge.")
			get_tree().quit()
			
	return area_points
	
func get_corners(position, sizex, sizey):
	var corner_list = []
	
	# Top left
	corner_list.append([position[0] - floor(sizex / 2), position[1] - floor(sizey / 2)])
	
	# Top right
	corner_list.append([position[0] + floor(sizex / 2), position[1] - floor(sizey / 2)])
	
	# Bottom right
	corner_list.append([position[0] + floor(sizex / 2), position[1] + floor(sizey / 2)])
	
	# Bottom left
	corner_list.append([position[0] - floor(sizex / 2), position[1] + floor(sizey / 2)])
	
	return corner_list
	
func get_wall_points(wall, corner_list: Array):
	
	var spare = corner_list.duplicate(true)
	spare.append(spare[0])
	
	var wall_points = []
	var start = spare[wall]
	
	if wall == 0:
		for r in range(start[0], spare[wall+1][0]+1):
			wall_points.append([r, start[1]])
	elif wall == 1:
		for r in range(start[1], spare[wall+1][1]+1):
			wall_points.append([start[0], r])
	elif wall == 2:
		for r in range(spare[wall+1][0]+1, start[0]):
			wall_points.append([r, start[1]])
	elif wall == 3:
		for r in range(spare[wall+1][1]+1, start[1]):
			wall_points.append([start[0], r])
			
	wall_points.erase(start)
	if len(wall_points) < 4:
		wall_points.erase(corner_list[wall+1])
	
	return wall_points

func check_x_input(x):
	if x % 2 == 0:
		x -= 1
	return x
	
func check_y_input(y):
	if y % 2 == 0:
		y -= 1
	return y
