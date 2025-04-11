extends CharacterBody2D

@onready var health_bar: ProgressBar = $healthBar
@onready var bullet: Node2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var hitbox: Area2D = $hitbox


@export var speed: float = 50
@export var damage: float = 10
@export var hp = 10

var isStopped = false
var direction: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = hp
	updateHealth()
	hitbox.damage = damage

func getDamage() -> float:
	return damage

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not isStopped:
		velocity.x = direction * speed
		animated_sprite_2d.play("move")
	else:
		velocity.x = 0
	
	if (is_on_wall() or not ray_cast_2d.is_colliding()) and timer.is_stopped() and not isStopped:
		isStopped = true
		animated_sprite_2d.play("idle")
		timer.start()
	move_and_slide()

func updateHealth():
	health_bar.value = hp
	if hp <= 0:
		queue_free()

func takeDamage(damageTaken):
	hp -= damageTaken
	updateHealth()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	hp -= PlayerData.rangedDamage
	updateHealth()


func _on_timer_timeout() -> void:
	self.scale.x *= -1
	direction *= -1
	await get_tree().create_timer(0.1).timeout
	isStopped = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	print("in hitbox")
	body.takeDamage(damage)
