extends Path2D
class_name MovingPlatform

@export var pathTime = 1.0
@export var ease : Tween.EaseType
@export var transition : Tween.TransitionType
@export var looping = false
@export var pathFollow2D: PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moveTween()

func moveTween():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(pathFollow2D, "progress_ratio", 1.0, pathTime).set_ease(ease).set_trans(transition)
	if !looping:
		tween.tween_property(pathFollow2D, "progress_ratio", 0.0, pathTime).set_ease(ease).set_trans(transition)
	else:
		tween.tween_property(pathFollow2D, "progress_ratio", 0.0, 0.0).set_ease(ease).set_trans(transition)
	
