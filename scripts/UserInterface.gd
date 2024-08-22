extends Control

@onready var lashing_num = $LashingNum
@onready var binding_lash_indicator = $BindingLashIndicator


func set_lashing_num(num: int):
	lashing_num.text = str(num)

func set_binding_indicator(on: bool):
	if on:
		binding_lash_indicator.color = Color(0, 255, 0)
	else:
		binding_lash_indicator.color = Color(255, 0, 0)
