extends Node

@onready var thunder_effects = $ThunderEffects

@onready var big_thunder_rumble = $ThunderEffects/BigThunderRumble
@onready var loud_thunder = $ThunderEffects/LoudThunder
@onready var peals_of_thunder = $ThunderEffects/PealsOfThunder
@onready var thunder = $ThunderEffects/Thunder

var thunder_sounds

var windows
var thunder_order = []
var thunder_time_min = 5
var thunder_time_max = 10
var wait = 0
var time = 0
var banned_values = []
var temporary_list = []
var item
var last_strike = null

# Called when the node enters the scene tree for the first time.
func _ready():
	windows = get_children()
	windows.erase(thunder_effects)
	thunder_sounds = [big_thunder_rumble, loud_thunder, peals_of_thunder, thunder]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if thunder_order == []:
		temporary_list = thunder_sounds.duplicate()
		while temporary_list != []:
			item = temporary_list.pick_random()
			thunder_order.append(item)
			temporary_list.erase(item)
		if last_strike == thunder_order[len(thunder_order)-1]:
			thunder_order.reverse()
		wait = randi_range(thunder_time_min, thunder_time_max)
		time = 0
		last_strike = thunder_order[len(thunder_order)-1]
	if time >= wait:
		# THUNDERSTRUCK!!
		for window_node in windows:
			window_node.enable_flash(thunder_order[0].name)
		thunder_order[0].play()
		thunder_order.remove_at(0)
		if thunder_order != []:
			wait = randi_range(thunder_time_min, thunder_time_max)
			time = 0
	else:
		time += delta
			
