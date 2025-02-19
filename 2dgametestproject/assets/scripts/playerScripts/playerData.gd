extends Node

var hp = 50
var maxHp = 100
var critRate = 5
var damage = 1
var speed = 5
var sprintSpeed = 10


func takeDamage(amount: int):
	hp = max(hp - amount, 0)  # Prevents negative HP
	print("HP:", hp)  # Replace with actual UI update logic

func addHp(amount: int):
	if GameManager.usePotion():
		hp = min(hp + amount, maxHp)
	
