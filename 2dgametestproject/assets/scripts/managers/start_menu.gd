extends Control



func _on_play_pressed() -> void:
	PlayerData.hp = PlayerData.maxHp
	get_tree().change_scene_to_file("res://assets/scenes/playable/area_0.tscn")


func _on_leave_game_pressed() -> void:
	get_tree().quit()


func _on_banana_pressed() -> void:
	GameManager.playerScene = preload("res://assets/scenes/playerStuff/player.tscn")


func _on_golem_pressed() -> void:
	GameManager.playerScene = preload("res://assets/scenes/playerStuff/golem_player.tscn")
