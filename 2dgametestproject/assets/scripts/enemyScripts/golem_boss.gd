extends CharacterBody2D

@onready var player_detector: Area2D = $playerDetector
@onready var boss_texure: AnimatedSprite2D = $bossTexure
@onready var player = get_parent().find_child("player")

enum State { Idle, Follow, MeleeAttack, HomingMissile, LaserBeam, ArmourBuff, Dash, Death }
var currentState = State.Idle
var previousState: State 

var direction : Vector2

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:

	move_and_slide()

func _process(delta: float) -> void:
	direction = player.position - position
	
	if direction.x < 0:
		boss_texure.scale.x = -1
	else:
		boss_texure.scale.x = 1
	

func changeState(newState):
	print("previous State: ", currentState)
	previousState = currentState
	currentState = newState
	print("new State: ", currentState)

func _on_player_detector_body_entered(body: Node2D) -> void:
	set_physics_process(true)
	changeState(State.Follow)
