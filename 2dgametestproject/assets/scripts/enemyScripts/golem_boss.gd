extends CharacterBody2D

@onready var player_detector: Area2D = $playerDetector
@onready var boss_texure: AnimatedSprite2D = $bossTexure
@onready var player = get_parent().find_child("player")
@onready var debug: Label = $debug
@onready var muzzle: Node2D = $bossTexure/muzzle
@onready var pivot: Node2D = $pivot
@onready var lazer_eye: AnimatedSprite2D = $pivot/lazerEye

@export var bullet: PackedScene

enum State { Idle, Follow, MeleeAttack, HomingMissile, LaserBeam, ArmourBuff, Dash, Death }
var currentState = State.Idle
var previousState: State 

var direction : Vector2

func _ready() -> void:
	set_physics_process(false)
	lazer_eye.stop()

func _physics_process(delta: float) -> void:
	checkForMelee()
	if currentState == State.Follow:
			velocity = direction.normalized() *40
	move_and_collide(velocity * delta)

func _process(delta: float) -> void:
	direction = player.position - position
	
	if direction.x < 0:
		boss_texure.scale.x = -1
	else:
		boss_texure.scale.x = 1
	
	
func checkForMelee():
	var distance = direction.length()
	if distance < 30:
		velocity = Vector2.ZERO 
		changeState(State.MeleeAttack)
	else:
		changeState(State.Follow)

func shoot():
	var bullets = bullet.instantiate()
	bullets.position = muzzle.global_position
	get_tree().current_scene.add_child(bullets)

func dash():
	var tween = create_tween()
	tween.tween_property(self ,"position", player.global_position, 0.8)
	await tween.finished

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
	if currentState == State.Idle or currentState == State.Follow:
		boss_texure.play("idle")
	elif currentState == State.MeleeAttack:
		boss_texure.play("meleeAttack")
	elif currentState == State.HomingMissile:
		boss_texure.play("rangedAttack")
		await boss_texure.animation_finished
		shoot()
		changeState(State.Dash)
	elif  currentState == State.Dash:
		boss_texure.play("glowing")
		await get_tree().create_timer(1.0).timeout
		await dash()
		changeState(State.Follow)
	elif currentState == State.LaserBeam:
		boss_texure.play("lazarCast")
		await boss_texure.animation_finished
		lazer_eye.play("charge")
		setTarget()
		await lazer_eye.animation_finished
		lazer_eye.stop()
		changeState(State.Dash)

func _on_player_detector_body_entered(body: Node2D) -> void:
	set_physics_process(true)
	changeState(State.Follow)


func _on_player_detector_body_exited(body: Node2D) -> void:
	set_physics_process(false)
	var chance = randi() % 2
	match chance:
		0:
			changeState(State.HomingMissile)
		1:
			changeState(State.LaserBeam)
