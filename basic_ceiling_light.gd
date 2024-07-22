extends Node3D

var START_POSITION
var light_on = true
@onready var omni_light_3d = $Lights/OmniLight3D

func init_light(start_position):
	START_POSITION = start_position
	transform.origin = START_POSITION
	
func flip_light():
	if light_on:
		omni_light_3d.hide()
		light_on = false
	else:
		omni_light_3d.show()
		light_on = true
		
func set_light_on():
	omni_light_3d.show()
	light_on = true
	
func set_light_off():
	omni_light_3d.hide()
	light_on = false
