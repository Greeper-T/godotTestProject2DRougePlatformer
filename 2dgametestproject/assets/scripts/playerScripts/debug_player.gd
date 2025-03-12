extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down")*500
	move_and_slide()
