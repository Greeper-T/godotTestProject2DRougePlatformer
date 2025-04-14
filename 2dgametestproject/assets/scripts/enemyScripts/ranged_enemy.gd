extends CharacterBody2D

@onready var health_bar: ProgressBar = $healthBar
@onready var switch_side_timer: Timer = $switchSideTimer
@onready var player_detector: RayCast2D = $playerDetector
@onready var edge_detector: RayCast2D = $edgeDetector
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Node2D = $muzzle
var player = null

@export var damage: float = 10
@export var speed: float = 50
@export var hp = 10
@export var shootingDistance = 200

const Bullet = preload("res://assets/scenes/enemy/enemy_bullet.tscn")
const BULLET = preload("res://assets/scenes/playerStuff/bullet.tscn")

var isOnFire = false
var fireTick = 0

enum State {IDLE, CHARGING, CHASING, DEATH, SHOOTING, DAMAGED, WANDERING}
var currentState = State.IDLE

var animationLock = false
var isStopped = false
var direction: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = hp
	updateHealth()

func getDamage() -> float:
	return damage

func _physics_process(delta: float) -> void:
	if animationLock:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	
	if not isStopped and currentState != State.SHOOTING:
		velocity.x = direction * speed
		playAnimation("move", State.WANDERING)
	else:
		velocity.x = 0
		playAnimation("idle", State.IDLE)
	
	if player_detector.is_colliding():
		var target = player_detector.get_collider()
		if target.name == "player":
			player = target
			if global_position.distance_to(player.global_position) < shootingDistance:
				stateTransition(State.SHOOTING)
			else:
				stateTransition(State.CHASING)
	
	if (is_on_wall() or not edge_detector.is_colliding()) and switch_side_timer.is_stopped() and not isStopped:
		isStopped = true
		playAnimation("idle", State.IDLE)
		switch_side_timer.start()
	move_and_slide()

func stateTransition(newState):
	if currentState != newState:
		currentState = newState
		match newState:
			State.CHASING:
				playAnimation("move", State.CHASING)
			State.SHOOTING:
				playAnimation("shoot", State.SHOOTING)
				shoot()

func takeDamage(damageTaken):
	hp -= damageTaken
	if PlayerData.wassabi:
		isOnFire = true
	if PlayerData.iceCreamCone:
		speed /= 2
		$AnimatedSprite2D.self_modulate = Color(0,.38,1,1)
		$slowDownTimer.start()
	updateHealth()

func shoot():
	if Bullet and player:
		var bullet = Bullet.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.direction = (player.global_position - global_position).normalized()
		bullet.damage = damage
		get_parent().add_child(bullet)

func updateHealth():
	health_bar.value = hp
	if hp <= 0:
		playAnimation("death", State.DEATH)
		animationLock = true
		await animated_sprite_2d.animation_finished
		PlayerData.money += randi_range(1,10)
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

func playAnimation(animName: String, new_state):
	if not animationLock and animated_sprite_2d.animation != animName:
		currentState = new_state
		animated_sprite_2d.play(animName)

func _on_switch_side_timer_timeout() -> void:
	self.scale.x *= -1
	direction *= -1
	await get_tree().create_timer(0.1).timeout
	isStopped = false


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not currentState == State.DAMAGED:
		hp -= PlayerData.rangedDamage
		updateHealth()
		playAnimation("takeDamage", State.DAMAGED)
		animationLock = true
		await animated_sprite_2d.animation_finished
		animationLock = false


func _on_animated_sprite_2d_animation_finished() -> void:
	animationLock = false
	if currentState == State.SHOOTING:
		shoot()
	if currentState == State.DAMAGED:
		if isStopped:
			playAnimation("idle", State.IDLE)
		else:
			playAnimation("move", State.WANDERING)


func _on_fire_area_body_entered(body: Node2D) -> void:
	var target = body
	if target.name == "player":
		player = target
		if global_position.distance_to(player.global_position) < shootingDistance:
			stateTransition(State.SHOOTING)
		else:
			stateTransition(State.CHASING)


func _on_fire_tick_timeout() -> void:
	if isOnFire:
		$AnimatedSprite2D.self_modulate = Color(1,.47,0,1)
		hp -= PlayerData.fireDamage
		fireTick += 1
	else:
		$AnimatedSprite2D.self_modulate = Color(1,1,1,1)
	if fireTick >= 5:
		isOnFire = false
		fireTick = 0


func _on_slow_down_timer_timeout() -> void:
	speed *= 2
	$AnimatedSprite2D.self_modulate = Color(1,1,1,1)
	$slowDownTimer.stop()
