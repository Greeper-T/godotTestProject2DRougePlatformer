extends Area2D

@onready var health_bar: ProgressBar = $healthBar
@onready var bullet: Node2D = $"."

var hp = 10
var damage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateHealth()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func updateHealth():
	health_bar.value = hp


func _on_hurtbox_area_entered(area: Area2D) -> void:
	hp -= 1
	updateHealth()
