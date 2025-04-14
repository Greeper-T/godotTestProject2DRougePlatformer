extends Node2D

const BULLET = preload("res://assets/scenes/playerStuff/bullet.tscn")
@onready var muzzle: Marker2D = $Marker2D

var canFire = true

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
	
	if Input.is_action_just_pressed("fireBullet") and canFire:
		if PlayerData.shotGun:
			var spread_angles = [0, deg_to_rad(-80), deg_to_rad(80)]  # center, left, right (in radians)

			for angle_offset in spread_angles:
				var bulletInstance = BULLET.instantiate()
				bulletInstance.global_position = muzzle.global_position
				bulletInstance.rotation = global_rotation + angle_offset
				if PlayerData.sharpCheddar:
					bulletInstance.set_collision_mask_value(3, false)
				get_tree().root.add_child(bulletInstance)
		else:
			var bulletInatance = BULLET.instantiate()
			bulletInatance.global_position = muzzle.global_position
			bulletInatance.rotation = global_rotation
			if PlayerData.sharpCheddar:
				bulletInatance.set_collision_mask_value(3, false)
			get_tree().root.add_child(bulletInatance)
		canFire = false
		$"../../fireDelay".start()


func _on_fire_delay_timeout() -> void:
	canFire = true
	$"../../fireDelay".stop()
