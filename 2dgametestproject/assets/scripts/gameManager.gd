extends Node

var currentArea = 1
var areaPath = "res://assets/scenes/playable/"

var potions = 0

func _ready():
	reset_potions()


func nextLevel():
	currentArea += 1
	var fullPath = areaPath + "area_" + str(currentArea) + ".tscn"
	get_tree().change_scene_to_file(fullPath)
	print("entered portal")



func set_up_area():
	reset_potions()


func add_potion():
	potions +=1
	


func reset_potions():
	potions = 0
