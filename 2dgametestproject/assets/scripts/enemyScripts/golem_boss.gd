extends CharacterBody2D

@onready var player_detector: Area2D = $playerDetector
@onready var boss_texure: AnimatedSprite2D = $bossTexure
var player = null
@onready var debug: Label = $debug
@onready var muzzle: Node2D = $bossTexure/muzzle
@onready var pivot: Node2D = $pivot
@onready var lazer_eye: AnimatedSprite2D = $pivot/lazerEye
@onready var hp_bar: ProgressBar = $UI/HpBar

@export var bullet: PackedScene

enum State { Idle, Follow, MeleeAttack, HomingMissile, LaserBeam, ArmourBuff, Dash, Death }
var currentState = State.Idle
var previousState: State 

var isOnFire = false
var fireTick = 0

var isSlow = false
var speed = 40

var direction : Vector2

var health = 100

func _ready() -> void:
	set_physics_process(false)
	lazer_eye.stop()
	updateHealthValue()
	#player = get_parent().find_child("player")

func _physics_process(delta: float) -> void:
	checkForMelee()
	if currentState == State.Follow:
			velocity = direction.normalized() * speed
	move_and_collide(velocity * delta)

func _process(delta: float) -> void:
	
	if player:
		direction = player.position - position
	
	if direction.x < 0:
		boss_texure.scale.x = -1
	else:
		boss_texure.scale.x = 1
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hp_bar.visible = !hp_bar.visible
	
func checkForMelee():
	var distance = direction.length()
	if distance < 30:
		velocity = Vector2.ZERO 
		changeState(State.MeleeAttack)

func shoot():
	var bullets = bullet.instantiate()
	bullets.position = muzzle.global_position
	bullets.player = player
	get_tree().current_scene.add_child(bullets)

func dash():
	var tween = create_tween()
	tween.tween_property(self ,"position", player.global_position, 0.8)
	await tween.finished
	set_physics_process(true)

func setTarget():
	var temp = (player.global_position - pivot.global_position).normalized()
	pivot.rotation = temp.angle()

func changeState(newState):
	if newState != currentState:
		previousState = currentState
		currentState = newState
		playAnimations()
		debug.text = State.keys()[currentState]

func playAnimations():
	if currentState == State.Idle or currentState == State.Follow and currentState != State.Death:
		boss_texure.play("idle")
	elif currentState == State.MeleeAttack and currentState != State.Death:
		boss_texure.play("meleeAttack")
	elif currentState == State.HomingMissile and currentState != State.Death:
		boss_texure.play("rangedAttack")
		await boss_texure.animation_finished
		shoot()
		changeState(State.Dash)
	elif  currentState == State.Dash and currentState != State.Death:
		boss_texure.play("glowing")
		await get_tree().create_timer(1.0).timeout
		await dash()
		changeState(State.Follow)
	elif currentState == State.LaserBeam and currentState != State.Death:
		boss_texure.play("lazarCast")
		await boss_texure.animation_finished
		lazer_eye.play("charge")
		setTarget()
		await lazer_eye.animation_finished
		lazer_eye.stop()
		changeState(State.Dash)
	elif currentState == State.ArmourBuff and currentState != State.Death:
		boss_texure.play("armorBuff")
		await boss_texure.animation_finished
		health += 25
		changeState(State.Follow)
	elif currentState == State.Death:
		set_physics_process(false)
		boss_texure.play("death")
		await boss_texure.animation_finished
		PlayerData.money += randi_range(20,50)
		GameManager.golemUnlocked = true
		if PlayerData.potatoShield:
			PlayerData.shieldActive = true
		#GameManager.playerScene = preload("res://assets/scenes/playerStuff/golem_player.tscn")
		queue_free()

func _on_player_detector_body_entered(body: Node2D) -> void:
	if currentState == State.Idle:
		set_physics_process(true)
		changeState(State.Follow)


func _on_player_detector_body_exited(body: Node2D) -> void:
	if currentState == State.Follow or currentState ==State.MeleeAttack:
		set_physics_process(false)
		var chance = randi() % 2
		match chance:
			0:
				changeState(State.HomingMissile)
			1:
				changeState(State.LaserBeam)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	health -= PlayerData.rangedDamage
	body.queue_free()
	updateHealthValue()

func updateHealthValue():
	hp_bar.value = health
	if health <= 0:
		changeState(State.Death)

func takeDamage(damageTaken):
	health -= damageTaken
	if PlayerData.wassabi:
		isOnFire = true
	if PlayerData.iceCreamCone:
		speed /= 2
		$bossTexure.self_modulate = Color(0,.38,1,1)
		$slowDownTimer.start()
	updateHealthValue()

func _on_boss_texure_animation_looped() -> void:
	if currentState == State.MeleeAttack:
		player.takeDamage(45)

var playerInLaserDamage = false

func _on_player_in_laser_body_entered(body: Node2D) -> void:
	playerInLaserDamage = true

func _on_player_in_laser_body_exited(body: Node2D) -> void:
	playerInLaserDamage = false

func _on_lazer_eye_frame_changed() -> void:
	if playerInLaserDamage and currentState == State.LaserBeam and lazer_eye.frame >= 9:
		player.takeDamage(20)


func _on_fire_tick_timeout() -> void:
	if isOnFire:
		$bossTexure.self_modulate = Color(1,.47,0,1)
		health -= PlayerData.fireDamage
		fireTick += 1
	else:
		$bossTexure.self_modulate = Color(1,1,1,1)
	if fireTick >= 5:
		isOnFire = false
		fireTick = 0


func _on_slow_down_timer_timeout() -> void:
	speed *= 2
	$bossTexure.self_modulate = Color(1,1,1,1)
	$slowDownTimer.stop()
