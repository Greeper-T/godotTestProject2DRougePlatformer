extends CharacterBody2D

@onready var health_bar: ProgressBar = $healthBar
@onready var timer: Timer = $Timer
@onready var player_detector: RayCast2D = $playerDetector
@onready var edge_detector: RayCast2D = $edgeDetector
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Node2D = $muzzle

@export var damage: float = 10

enum State {IDLE, CHARGING, CHASING, DEATH, SHOOTING, DAMAGED, WANDERING}
var currentState = State.IDLE
