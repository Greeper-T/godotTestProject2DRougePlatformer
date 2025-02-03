extends Node2D

@export var playerController : PlayerController

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	if playerController.direction == 1:
		animatedSprite.flip_h = false
	elif playerController.direction == -1:
		animatedSprite.flip_h = true
		
	if abs(playerController.velocity.x) > 0:
		animatedSprite.play("move")
	else:
		animatedSprite.play("idle")
		
		
	if playerController.velocity.y < 0:
		animatedSprite.play("jump")
	elif playerController.velocity.y > 0:
		animatedSprite.play("fall")
