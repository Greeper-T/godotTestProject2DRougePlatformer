extends Path2D
class_name MovingPlatform

@export var pathFollow2D: PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moveTween()

func moveTween():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(pathFollow2D, "progress_ratio", 1.0, 1.0)
