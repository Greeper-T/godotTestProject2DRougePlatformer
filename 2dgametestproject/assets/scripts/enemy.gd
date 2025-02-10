extends CharacterBody2D

@onready var health_bar: ProgressBar = $healthBar
@onready var bullet: Node2D = $"."

var hp = 10
var damage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateHealth()

func _physics_process(delta: float) -> void:
	
	
	
	move_and_slide()

func updateHealth():
	health_bar.value = hp
	if hp == 0:
		queue_free()



func _on_hurtbox_body_entered(body: Node2D) -> void:
	hp -= 1
	updateHealth()
