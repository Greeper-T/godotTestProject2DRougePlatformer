extends Node2D

const BULLET = preload("res://assets/scenes/playerStuff/bullet.tscn")
@onready var muzzle: Marker2D = $Marker2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0 , 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y  = -1
	else:
		scale.y = 1
	
	if Input.is_action_just_pressed("fireBullet"):
		var bulletInatance = BULLET.instantiate()
		get_tree().root.add_child(bulletInatance)
		bulletInatance.global_position = muzzle.global_position
		bulletInatance.rotation = rotation
