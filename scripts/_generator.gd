extends Node

var MAP_KEY
var CENTER_RING_ROOM_NUM
var SECONDARY_RINGS
var LEVELS
var MIN_ROOM_SIZE
var MAX_ROOM_SIZE
var CORRIDOR_HEIGHT
var ROOM_HEIGHT
var ROOM_SHIFT_LIMIT
var CENTER_RING_RADIUS
var CORRIDOR_THICKNESS
var RING_TILT
var TILE_MAP_SIZE
var CENTER_RING_LOCATION
var CENTER_RING_ROOMS
var CENTER_RING_CORRIDORS
var SECONDARY_RING_ROOMS
var SECONDARY_RING_CORRIDORS
var UP_ROOM
var DOWN_ROOM
var DUNGEON

var random
const Room = preload("res://scripts/Room.gd")
const Corridor = preload("res://scripts/Corridor.gd")
const SimpleCorridor = preload("res://scripts/SimpleCorridor.gd")

func _init(
	levels: int,
	center_ring_room_num: int,
	center_ring_radius: int,
	secondary_rings: int,
	min_room_size: int,
	max_room_size: int,

	corridor_height: int,
	room_height: int,

	room_shift_limit: int,
	corridor_thickness: int,
	ring_tilt: int,

	map_key: Dictionary,
	):
		
	MAP_KEY = map_key
	CENTER_RING_ROOM_NUM = center_ring_room_num
	SECONDARY_RINGS = secondary_rings
	LEVELS = levels
	
	MIN_ROOM_SIZE = min_room_size + 2 # wall hack
	MAX_ROOM_SIZE = max_room_size + 2 # wall hack
	
	CORRIDOR_HEIGHT = corridor_height
	ROOM_HEIGHT = room_height
	ROOM_SHIFT_LIMIT = room_shift_limit
	CENTER_RING_RADIUS = center_ring_radius
	CORRIDOR_THICKNESS = corridor_thickness
	
	if ring_tilt < 0 or ring_tilt > 45:
		print("Ring tilt must be between 0 and 45, not this: "+str(ring_tilt))
		get_tree().quit()
	else:
		RING_TILT = ring_tilt
		
	# Initial data
	TILE_MAP_SIZE = [int(CENTER_RING_RADIUS * (SECONDARY_RINGS + 7)), int(CENTER_RING_RADIUS * (SECONDARY_RINGS + 7))]
	CENTER_RING_LOCATION = [int(CENTER_RING_RADIUS * (SECONDARY_RINGS + 7) / 2), int(CENTER_RING_RADIUS * (SECONDARY_RINGS + 7) / 2)]
	
	# Prep variables
	CENTER_RING_ROOMS = []
	CENTER_RING_CORRIDORS = []
	
	SECONDARY_RING_ROOMS = {}
	SECONDARY_RING_CORRIDORS = {}
	
	for x in range(secondary_rings):
		SECONDARY_RING_ROOMS[x] = []
		
	for x in range(SECONDARY_RINGS):
		SECONDARY_RING_CORRIDORS[x] = []
		
	DUNGEON = build_dungeon()
	
	
	
func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()
	
	
func build_dungeon():
	var dungeon = []
	
	for x in range(LEVELS):
		dungeon.append(
			build_level()
		)
		print("Level "+str(x)+" built")
	return dungeon
	
func build_level():
	
	var tile_map = build_blank(TILE_MAP_SIZE[0], TILE_MAP_SIZE[1])
	
	# Build rings
	
	var rooms = []
	var corridors = []
	var simple_corridors = []
	
	# Place rooms
	
	# Get points
	var point_list
	point_list = find_center_ring_points(
		CENTER_RING_LOCATION,
		CENTER_RING_ROOM_NUM,
		RING_TILT,
		CENTER_RING_RADIUS,
		ROOM_SHIFT_LIMIT
	)
	
	var h = 0
	var w = CENTER_RING_ROOM_NUM
	var i = CENTER_RING_RADIUS
	point_list = [point_list.duplicate(true)]
	
	for x in range(SECONDARY_RINGS):
		
		if h == 0:
			h += 2
		else:
			h += h
			
		w += w
		
		# radius
		if x == 0:
			i += i
		else:
			i += CENTER_RING_RADIUS
			
		var r = find_center_ring_points(
			CENTER_RING_LOCATION,
			w,
			RING_TILT,
			i,
			ROOM_SHIFT_LIMIT
		)
		
		point_list.append(r.duplicate(true))
		
	# Pick rooms to have stairways
	var all_points = []
	for ring in point_list:
		for point in ring:
			all_points.append(point)
			
	UP_ROOM = all_points[random.randi(0, len(all_points)-1)]
	all_points.erase(UP_ROOM)
	DOWN_ROOM = all_points[random.randi(0, len(all_points)-1)]
	
	# Create the rooms
	for ring in point_list:
		var u = []
		for point in ring:
			u = place_room(u, point)
		rooms.append(u.duplicate(true))
		
	# Apply data to tile map
	for ring in rooms:
		for room in ring:
			for point in room.AREA_POINTS:
				tile_map[point[1]][point[0]] = MAP_KEY["room tile"]
			for point in room.WALL_AREA_POINTS:
				tile_map[point[1]][point[0]] = MAP_KEY["wall tile"]
				
	var mid_point_list = []
	
	for ring in rooms:
		
		var a = []
		
		# pretender
		ring.append(ring[0])
		
		# Create corridors
		for t in range(len(ring) - 1, 0, -1):
			var new_c = Corridor.new(
				ring[t],
				ring[t - 1],
				CORRIDOR_THICKNESS,
				[],
				tile_map,
				MAP_KEY
			)
			if not new_c.AREA_POINTS == []:
				ring[t] = new_c.get_modified_rooms()[0]
				ring[t - 1] = new_c.get_modified_rooms()[1]
				corridors.append(new_c)
				a.append(new_c.get_midpoint())
				
		mid_point_list.append(a.duplicate(true))
		a.clear()
		ring.erase(ring[len(ring)-1])
		
	# Create inter-ring corridors
	for t in range(len(mid_point_list)-1):
		var s = 0
		var new_c
		for point in mid_point_list[t]:
			
			var l = 2 # NOTE 2
			
			var k = random.randi(0, 1)
			s += k
			l -= k
			new_c = SimpleCorridor.new(
				point,
				mid_point_list[t+1][s],
				CORRIDOR_THICKNESS,
				[],
				tile_map,
				MAP_KEY
			)
			if not new_c.AREA_POINTS == []:
				simple_corridors.append(new_c)
			s += l
			
	# Apply data to tile map
	
	for corridor in corridors:
		for point in corridor.AREA_POINTS:
			tile_map[point[1]][point[0]] = MAP_KEY["corridor tile"]
			
	for corridor in simple_corridors:
		for point in corridor.AREA_POINTS:
			tile_map[point[1]][point[0]] = MAP_KEY["corridor tile"]
			
	for ring in rooms:
		for room in ring:
			for point in room.STAIRWELL_AREA_POINTS:
				tile_map[point[1]][point[0]] = MAP_KEY["stair tile"]
				
	for corridor in corridors:
		var start = corridor.STARTING_POINT
		var end = corridor.END_POINT
		tile_map[start[1]][start[0]] = MAP_KEY["door tile"]
		tile_map[end[1]][end[0]] = MAP_KEY["door tile"]
		
		# fix null area in corridor around door
		var f = corridor.STARTING_DIRECTION
		var o
		var k
		if f == 0:
			o = 0 #x
			k = -1 #y
		elif f == 1:
			o = 1
			k = 0
		elif f == 2:
			o = 0
			k = 1
		elif f == 3:
			o = -1
			k = 0
		corridor.AREA_POINTS.append([start[0] + o, start[1] + k])
		tile_map[start[1]+k][start[0]+o] = MAP_KEY["corridor tile"]
		
		f = corridor.ENDING_DIRECTION
		if f == 0:
			o = 0 #x
			k = -1 #y
		elif f == 1:
			o = 1
			k = 0
		elif f == 2:
			o = 0
			k = 1
		elif f == 3:
			o = -1
			k = 0
		corridor.AREA_POINTS.append([end[0] + o, end[1] +  k])
		tile_map[end[1]+k][end[0]+o] = MAP_KEY["corridor tile"]
		
	var level = {
		"tile_map":tile_map,
		"start":UP_ROOM,
		"end":DOWN_ROOM,
		"ch":CORRIDOR_HEIGHT,
		"rh":ROOM_HEIGHT
	}
	
	return level
		
	
	
func build_blank(x: int, y: int):
	
	var map = []
	for a in range(y):
		var row = []
		for b in range(x):
			row.append(MAP_KEY["blank tile"])
		map.append(row.duplicate(true))
	return map
	
func find_center_ring_points(
	center_point_location: Array,
	room_count: int,
	base_direction: float,
	radius: int,
	point_shift_limit: int,
	skip_points=[],
	):
	
	var points = []
	var increment = 360 / room_count
	
	for x in range(room_count):
		var t = 0
		for object in skip_points:
			if object[1] == x:
				points.append(object[0])
				t = 1
		if t == 1:
			base_direction += increment
			continue
			
		var leg_x = radius * cos(deg_to_rad(base_direction))
		var leg_y = radius * sin(deg_to_rad(base_direction))
		
		# round
		if leg_x + 0.5 > ceil(leg_x):
			leg_x = ceil(leg_x)
		else:
			leg_x = floor(leg_x)
			
		if leg_y + 0.5 > ceil(leg_y):
			leg_y = ceil(leg_y)
		else:
			leg_y = floor(leg_y)
			
		# random
		leg_x += random.randi(-point_shift_limit, point_shift_limit)
		leg_y += random.randi(-point_shift_limit, point_shift_limit)
		
		# apply
		points.append([center_point_location[0] + leg_x, center_point_location[1] + leg_y])
		
		# adjust angle
		base_direction += increment
		
	return points
	
func place_room(ring: Array, coordinates: Array):
	
	var size_x = random.randi(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var size_y = random.randi(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var a
	
	if coordinates == UP_ROOM:
		a = 2
	elif coordinates == DOWN_ROOM:
		a = 1
	else:
		a = 0
		
	ring.append(
		Room.new(coordinates, size_x, size_y, a)
	)
	
	return ring
	
	
	
