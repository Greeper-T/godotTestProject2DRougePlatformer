extends Control

@onready var player: Sprite2D = $Player
var canPlay = true

func _on_play_pressed() -> void:
	if canPlay:
		PlayerData.hp = PlayerData.maxHp
		GameManager.currentPhase = 0
		PlayerData.money = 0
		get_tree().change_scene_to_file("res://assets/scenes/playable/area_0.tscn")


func _on_leave_game_pressed() -> void:
	get_tree().quit()


func _on_banana_pressed() -> void:
	GameManager.playerScene = preload("res://assets/scenes/playerStuff/player.tscn")
	player.visible = true
	#$banana.add_theme_color_override("font_color", Color(1,0.85,0,1))
	$golem.add_theme_color_override("font_color", Color("#000000"))
	$golem2.visible = false
	canPlay = true


func _on_golem_pressed() -> void:
	GameManager.playerScene = preload("res://assets/scenes/playerStuff/golem_player.tscn")
	if not GameManager.golemUnlocked:
		$golem2.modulate = Color(0,0,0,1)
		canPlay = false
	else:
		$golem2.modulate = Color(1,1,1,1)
		canPlay = true
	$banana.add_theme_color_override("font_color", Color("#000000"))
	#$golem.add_theme_color_override("font_color", Color("#0059fd"))
	$golem2.visible = true
	player.visible = false
	
