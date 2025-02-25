extends Node

var hp = 50
var maxHp = 100

enum PlayerState { IDLE, MOVING, JUMPING, FALLING, GROUND_POUND, SPRINTING}
var currentState = PlayerState.IDLE

func takeDamage(amount: int):
	hp = max(hp - amount, 0)  # Prevents negative HP
	if hp == 0:
		get_tree().change_scene_to_file("res://assets/scenes/areaFunctions/start_menu.tscn")  
	print("HP:", hp)  # Replace with actual UI update logic

func addHp(amount: int):
	if GameManager.usePotion():
		hp = min(hp + amount, maxHp)
	
