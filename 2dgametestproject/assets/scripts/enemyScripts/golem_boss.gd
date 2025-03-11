extends CharacterBody2D

@onready var player_detector: Area2D = $playerDetector
@onready var boss_texure: AnimatedSprite2D = $bossTexure
@onready var player = get_parent().find_child("player")
@onready var debug: Label = $debug

enum State { Idle, Follow, MeleeAttack, HomingMissile, LaserBeam, ArmourBuff, Dash, Death }
var currentState = State.Idle
var previousState: State 

var direction : Vector2

func _ready() -> void:
	set_physics_process(false)

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

func changeState(newState):
	if newState != currentState:
		previousState = currentState
		currentState = newState
		playAnimations()
		debug.text = State.keys()[currentState]

func playAnimations():
	if currentState == State.Idle:
		boss_texure.play("idle")
	elif currentState == State.MeleeAttack:
		boss_texure.play("meleeAttack")

func _on_player_detector_body_entered(body: Node2D) -> void:
	set_physics_process(true)
	changeState(State.Follow)


func _on_player_detector_body_exited(body: Node2D) -> void:
	set_physics_process(false)
	changeState(State.Idle)
