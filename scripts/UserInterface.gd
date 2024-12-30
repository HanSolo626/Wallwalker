extends Control

@onready var lashing_num = $LashingNum
@onready var binding_lash_indicator = $BindingLashIndicator
@onready var death_screen = $DeathScreen

signal death_animation_done

func set_lashing_num(num: int):
	lashing_num.text = str(num)

func set_binding_indicator(on: bool):
	if on:
		binding_lash_indicator.color = Color(0, 255, 0)
	else:
		binding_lash_indicator.color = Color(255, 0, 0)
		
func enable_death_screen():
	death_screen.show()
	death_screen.modulate.a = 0.384
	
func disable_death_screen():
	death_screen.hide()
	death_screen.modulate.a = 0.384

func _process(delta):
	if death_screen.visible:
		death_screen.modulate.a += delta * 0.07
		if death_screen.modulate.a >= 1:
			death_animation_done.emit()
			disable_death_screen()
