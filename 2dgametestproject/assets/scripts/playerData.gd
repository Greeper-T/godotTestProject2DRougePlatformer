extends Node

var hp = 50
var maxHp = 100

func takeDamage(amount: int):
	hp = max(hp - amount, 0)  # Prevents negative HP
	print("HP:", hp)  # Replace with actual UI update logic

func addHp(amount: int):
	hp = min(hp + amount, maxHp)
