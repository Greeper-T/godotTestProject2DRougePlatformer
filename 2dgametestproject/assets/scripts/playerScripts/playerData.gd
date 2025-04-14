extends Node

var hp = 100.0
var maxHp = 100.0
var critRate = 5.0
var rangedDamage = 4.0
var meleeDamage = 6.0
var fireDamage = 2.0
var speed = 5.0
var sprintSpeed = 10.0
var jumpsLeft = 1
var totalJumps = 2
var defense = 0
var lives = 1

var potatoShield = false
var shieldActive = false

var wassabi = false

var sharpCheddar = false

var iceCreamCone = false

var grapeShot = false

var shotGun = false

var contactDamage = false

var money = 0

var pc : PlayerController


enum PlayerState { IDLE, MOVING, JUMPING, FALLING, GROUND_POUND, SPRINTING, DEATH, MELEE_ATTACK, SHOOTING }
var currentState = PlayerState.IDLE

func takeDamage(amount: float):
	if not shieldActive:
		hp = max(hp - amount, 0)  # Prevents negative HP
	else:
		shieldActive = false
	

func die():
	if hp <= 0:
		lives-=1
		if lives<=0:
			get_tree().change_scene_to_file("res://assets/scenes/areaFunctions/start_menu.tscn")
			GameManager.currentArea = 1
		else:
			hp = maxHp

func addHp(amount: float):
	if GameManager.usePotion():
		hp = min(hp + amount, maxHp)

func calcItem(item:Item):
	speed+=item.itemSpeedIncrease
	hp+=item.itemHealthIncrease
	maxHp+=item.itemHealthIncrease
	critRate+=item.itemCritAdd
	rangedDamage+=item.itemRangedDamage
	rangedDamage+=item.itemMeleeDamage
	totalJumps+=item.itemJumpIncrease
	defense += item.itemDefense
	
