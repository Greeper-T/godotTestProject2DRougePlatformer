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



func _on_portal_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		await GameManager.nextLevel()

func _process(delta: float) -> void:
	if PlayerData.hp <= 0:
		queue_free()
