extends Control



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/playable/area_1.tscn")


func _on_leave_game_pressed() -> void:
	get_tree().quit()
