extends Node2D

var player_scene = preload("res://assets/scenes/playerStuff/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = GameManager.playerScene.instantiate()
	player.global_position = $playerSpawner.global_position
	add_child(player)
