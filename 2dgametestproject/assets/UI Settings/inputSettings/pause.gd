extends Node2D

@onready var pauseScreen: Control = $CanvasLayer/InputSetting
@onready var player_spawner: Node2D = $playerSpawner
@onready var boss_spawner: Node2D = $bossSpawner

var Boss = preload("res://assets/scenes/enemy/golem_boss.tscn")

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
