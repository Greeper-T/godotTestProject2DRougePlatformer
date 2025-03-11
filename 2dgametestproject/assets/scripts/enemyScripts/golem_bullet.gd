extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_parent().find_child("player")

var acceleration: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	acceleration = (player.position - position).normalized() * 700
	
	velocity += acceleration * delta
	rotation = velocity.angle()
	
	velocity = velocity.limit_length(150)
	
	position += velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
