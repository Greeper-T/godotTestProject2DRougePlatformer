extends Area2D

var damage: float = 10

func getDamage():
	return damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
