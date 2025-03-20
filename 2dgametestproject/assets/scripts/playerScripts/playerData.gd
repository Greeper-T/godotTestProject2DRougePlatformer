extends Node

var hp = 100
var maxHp = 100
var critRate = 5
var damage = 1
var speed = 3

var pc : PlayerController




enum PlayerState { IDLE, MOVING, JUMPING, FALLING, GROUND_POUND, SPRINTING}
var currentState = PlayerState.IDLE

func takeDamage(amount: float):
	hp = max(hp - amount, 0)  # Prevents negative HP
	if hp == 0:
		get_tree().change_scene_to_file("res://assets/scenes/areaFunctions/start_menu.tscn")  
	print("HP:", hp)  # Replace with actual UI update logic

func addHp(amount: int):
	if GameManager.usePotion():
		hp = min(hp + amount, maxHp)

func calcItem(item:Item):
	for n in range(0,item.itemAmt):
		speed+=item.itemSpeedIncrease
		hp+=item.itemHealthIncrease
		maxHp+=item.itemHealthIncrease
		critRate+=item.itemCritAdd
		damage+=item.itemDamage
