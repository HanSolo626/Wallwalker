extends Control



func _on_exit_pressed():
	get_tree().quit()


func _on_load_dungeon_pressed():
	get_tree().change_scene_to_file("res://alpha_levels/lashing_binding_test_area/lashing_binding_test_area.tscn")
