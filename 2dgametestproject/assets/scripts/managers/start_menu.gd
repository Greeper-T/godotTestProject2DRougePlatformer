extends Control

var canPlay = true
var selection = 500

func _on_play_pressed() -> void:
	if canPlay:
		PlayerData.hp = PlayerData.maxHp
		GameManager.currentPhase = 0
		PlayerData.money = 0
		GameManager.timerRunning = true
		get_tree().change_scene_to_file("res://assets/scenes/playable/area_0.tscn")


func _on_leave_game_pressed() -> void:
	get_tree().quit()

func updateTheSprite():
	if selection % 2 == 0:
		$HBoxContainer/Player.visible = true
		$HBoxContainer/golem2.visible = false
		GameManager.playerScene = preload("res://assets/scenes/playerStuff/player.tscn")
	else:
		$HBoxContainer/golem2.visible = true
		$HBoxContainer/Player.visible = false
		GameManager.playerScene = preload("res://assets/scenes/playerStuff/golem_player.tscn")

func _on_left_button_pressed() -> void:
	selection -= 1
	updateTheSprite()


func _on_right_button_pressed() -> void:
	selection += 1
	updateTheSprite()


func _on_keybinds_pressed() -> void:
	if $InputSetting.visible:
		$InputSetting.visible = false
	else:
		$InputSetting.visible = true
