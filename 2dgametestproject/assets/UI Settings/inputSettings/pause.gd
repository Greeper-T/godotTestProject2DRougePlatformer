extends Node2D

@onready var pauseScreen: Control = $CanvasLayer/InputSetting

var gamePaused = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		gamePaused = !gamePaused
		if gamePaused:
			Engine.time_scale = 0
			pauseScreen.setVisibility()
		else:
			Engine.time_scale = 1
			pauseScreen.setVisibility()
