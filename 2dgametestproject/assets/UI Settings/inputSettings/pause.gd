extends Node2D

@onready var pauseScreen: Control = $CanvasLayer/InputSetting
@onready var player_spawner: Node2D = $playerSpawner
@onready var boss_spawner: Node2D = $bossSpawner

var Boss = preload("res://assets/scenes/enemy/golem_boss.tscn")

var gamePaused = false

func _ready() -> void:
	var player = GameManager.playerScene.instantiate()
	player.global_position = player_spawner.global_position
	player.name = "player"
	add_child(player)
	await get_tree().process_frame
	var boss = Boss.instantiate()
	boss.global_position = $bossSpawner.global_position
	add_child(boss)
	boss.player = player

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		gamePaused = !gamePaused
		if gamePaused:
			Engine.time_scale = 0
			pauseScreen.setVisibility()
		else:
			Engine.time_scale = 1
			pauseScreen.setVisibility()


func _process(delta: float) -> void:
	if PlayerData.hp <= 0:
		queue_free()


func _on_portal_detection_body_entered(body: Node2D) -> void:
	await GameManager.nextLevel()
