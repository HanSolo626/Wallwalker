extends Control


@onready var lashing_num = $LashingNum
@onready var binding_lash_indicator = $BindingLashIndicator
@onready var death_screen = $DeathScreen
@onready var area_highlighter = $AreaHighlighter
@onready var left = $AreaHighlighter/Left
@onready var right = $AreaHighlighter/Right
@onready var top = $AreaHighlighter/Top
@onready var bottom = $AreaHighlighter/Bottom


var left_m
var right_m
var top_m
var bottom_m
var current_aplpha_value = 0

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
	
func set_highlighter_alpha_all(alpha_value: float):
	if current_aplpha_value != alpha_value:
		current_aplpha_value = alpha_value
		left.modulate.a = alpha_value
		right.modulate.a = alpha_value
		top.modulate.a = alpha_value
		bottom.modulate.a = alpha_value
		print(left_m.a)

func set_highlighter_color_all(color_value: Color):
	left_m = color_value
	right_m = color_value
	top_m = color_value
	bottom_m = color_value
	
func _ready():
	left_m = left.modulate
	right_m = right.modulate
	top_m = top.modulate
	bottom_m = bottom.modulate

func _process(delta):
	if death_screen.visible:
		death_screen.modulate.a += delta * 0.07
		if death_screen.modulate.a >= 1:
			death_animation_done.emit()
			disable_death_screen()
