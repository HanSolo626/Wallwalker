extends Node3D

@onready var background = $Background/Background
@onready var spot_light_3d = $Background/SpotLight3D

var flash_on = false
var counter = 0
var flash_value = 0
var dark_values = Color(0,0,0,1)
var current_lightning_strike
var current_light
var time = 0
var light_index = 0
var weight = 1.5

# [ [time mark, intensity (5 max), fade_rate_per_second] ]


const LIGHTING_STRIKES = {
	"BigThunderRumble": [ [0.5, 2, 7], [1, 5, 5], [2, 4, 6], [6.7, 4, 9], [8, 3, 9], [8.5, 5, 6], [10.5, 3, 7], ],
	"Thunder": [ [0, 3, 11], [0.4, 5, 8], [1.3, 4, 7], [2, 3, 7], ],
	"PealsOfThunder": [ [0.5, 3.5, 9], [0.65, 3, 7], [1.7, 2.5, 8] ],
	"LoudThunder": [ [0.1, 5, 8], [0.5, 4, 5], [2.5, 2, 5] ], 
}


func enable_flash(thunder_name: String):
	#background.mesh.material.albedo_color = Color(flash_value, flash_value, flash_value, 1)
	flash_on = true
	#spot_light_3d.show()
	current_lightning_strike = LIGHTING_STRIKES[thunder_name]
	current_light = current_lightning_strike[0]
	light_index = 0
	time = 0

func disable_flash():
	background.mesh.material.albedo_color = dark_values
	flash_on = false
	counter = 0
	
	#spot_light_3d.hide()
	
func update_flash(delta):
	if light_index != len(current_lightning_strike):
		if len(current_lightning_strike) != light_index+1 and time >= current_lightning_strike[light_index + 1][0]:
			current_light = current_lightning_strike[light_index + 1]
			flash_value = current_light[1]
			light_index += 1
		else:
			flash_value -= current_light[2] * delta
			time += delta
	elif flash_value > 0:
		flash_value -= current_light[2] * delta
	if flash_value < 0 and light_index == len(current_lightning_strike)-1:
		flash_value = 0
		time = 0
		disable_flash()
	if flash_value >= 0:
		background.mesh.material.albedo_color = Color(flash_value*weight, flash_value*weight, flash_value*weight, 1)
		spot_light_3d.light_energy = (flash_value*weight) * 3
	else:
		background.mesh.material.albedo_color = Color(0, 0, 0, 1)
		spot_light_3d.light_energy = 0

	
func _ready():
	disable_flash()
	

func _process(delta):
	
	if flash_on:
		update_flash(delta)
	
	
