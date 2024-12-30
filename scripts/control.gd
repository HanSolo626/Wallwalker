extends Control

@onready var user_interface = $UserInterface
@onready var victory_menu = $VictoryMenu
@onready var pause_menu = $PauseMenu


func get_user_interface():
	return user_interface

func get_victory_menu():
	return victory_menu

func get_pause_menu():
	return pause_menu
