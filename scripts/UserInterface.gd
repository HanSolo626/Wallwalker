extends Control

@onready var lashing_num = $LashingNum
@onready var binding_lash_indicator = $BindingLashIndicator
@onready var death_screen = $DeathScreen


func set_lashing_num(num: int):
	lashing_num.text = str(num)

func set_binding_indicator(on: bool):
	if on:
		binding_lash_indicator.color = Color(0, 255, 0)
	else:
		binding_lash_indicator.color = Color(255, 0, 0)
		
func enable_death_screen():
	death_screen.show()
	
func disable_death_screen():
	death_screen.hide()
