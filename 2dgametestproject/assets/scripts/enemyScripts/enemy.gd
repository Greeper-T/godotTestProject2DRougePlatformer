extends CharacterBody2D

@onready var health_bar: ProgressBar = $healthBar
@onready var bullet: Node2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = $RayCast2D

const BULLET = preload("res://assets/scenes/playerStuff/bullet.tscn")

var isOnFire = false
var fireTick = 0

@export var speed: float = 50
@export var damage: float = 10
@export var hp = 10

var isStopped = false
var direction: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = hp
	updateHealth()

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
		PlayerData.money += randi() % 6
		if PlayerData.potatoShield:
			PlayerData.shieldActive = true
		if PlayerData.grapeShot:
			await explode()
		queue_free()

func explode():
	for i in range(randi_range(5,10)):  # Change the number for how many bullets you want
			var bulletInstance = BULLET.instantiate()
			bulletInstance.global_position = global_position

			var random_angle = randf() * TAU  # TAU is 2*PI, full circle in radians
			bulletInstance.rotation = random_angle
			bulletInstance.SPEED = 750
			if PlayerData.sharpCheddar:
				bulletInstance.set_collision_mask_value(3, false)
			
			get_tree().root.add_child(bulletInstance)

func takeDamage(damageTaken):
	hp -= damageTaken
	print(PlayerData.iceCreamCone)
	if PlayerData.wassabi:
		isOnFire = true
	if PlayerData.iceCreamCone:
		print("slowed")
		speed /= 2
		$AnimatedSprite2D.self_modulate = Color(0,.38,1,1)
		$slowDownTimer.start()
	updateHealth()

func _on_timer_timeout() -> void:
	self.scale.x *= -1
	direction *= -1
	await get_tree().create_timer(0.1).timeout
	isStopped = false

func _on_fire_tick_damage_timeout() -> void:
	if isOnFire:
		$AnimatedSprite2D.self_modulate = Color(1,.47,0,1)
		hp -= PlayerData.fireDamage
		updateHealth()
		fireTick += 1
	elif $slowDownTimer.is_stopped():
		$AnimatedSprite2D.self_modulate = Color(1,1,1,1)
	if fireTick >= 5:
		isOnFire = false
		fireTick = 0


func _on_slow_down_timer_timeout() -> void:
	speed *= 2
	$AnimatedSprite2D.self_modulate = Color(1,1,1,1)
	$slowDownTimer.stop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("in hitbox")
	if body.is_in_group("player"):
		body.takeDamage(damage)
