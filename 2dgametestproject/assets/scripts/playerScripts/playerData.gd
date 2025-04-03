extends Node

var hp = 100.0
var maxHp = 100.0
var critRate = 5.0
var damage = 4.0
var speed = 5.0
var sprintSpeed = 10.0

var pc : PlayerController


enum PlayerState { IDLE, MOVING, JUMPING, FALLING, GROUND_POUND, SPRINTING, DEATH, MELEE_ATTACK, SHOOTING }
var currentState = PlayerState.IDLE

func takeDamage(amount: float):
	hp = max(hp - amount, 0)  # Prevents negative HP
	if hp == 0:
		get_tree().change_scene_to_file("res://assets/scenes/areaFunctions/start_menu.tscn")
		GameManager.currentArea = 1  

func addHp(amount: float):
	if GameManager.usePotion():
		hp = min(hp + amount, maxHp)

func calcItem(item:Item):
	for n in range(0,item.itemAmt):
		speed+=item.itemSpeedIncrease
		hp+=item.itemHealthIncrease
		maxHp+=item.itemHealthIncrease
		critRate+=item.itemCritAdd
		damage+=item.itemDamage
