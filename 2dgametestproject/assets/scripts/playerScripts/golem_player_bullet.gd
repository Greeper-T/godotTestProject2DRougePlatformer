extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var enemy = null

var acceleration: Vector2 = Vector2.ZERO
var speed: Vector2 = Vector2.ZERO
var rotationSpeed: float = 2.0


func _physics_process(delta: float) -> void:
	
	#var direction = (player.global_position - global_position).normalized()
	#
	#var targetAngle = direction.angle()
	#rotation = lerp_angle(rotation, targetAngle,rotationSpeed * delta)
	#
	#position += Vector2.RIGHT.rotated(rotation) * speed * delta
	if enemy:
		acceleration = (enemy.global_position - position).normalized() * 700
		
		speed += acceleration * delta
		rotation = speed.angle()
		
		speed = speed.limit_length(150)
		
		position += speed * delta	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("takeDamage"):
		body.takeDamage(PlayerData.damage)
		queue_free()


func _on_check_for_first_enemy_body_entered(body: Node2D) -> void:
	enemy = body
