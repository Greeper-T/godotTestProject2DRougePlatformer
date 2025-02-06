extends Node

var currentArea = 1
var areaPath = "res://assets/scenes/playable/"

var potions = 0
var area_container : Node2D
var player : PlayerController
var hud : HUD


func _ready():
	hud = get_tree().get_first_node_in_group("hud")
	area_container = get_tree().get_first_node_in_group("area_container")
	player = get_tree().get_first_node_in_group("player")
	reset_potions()


func nextLevel():
	currentArea += 1
	var fullPath = areaPath + "area_" + str(currentArea) + ".tscn"
	get_tree().change_scene_to_file(fullPath)
	print("entered portal")



func set_up_area():
	reset_potions()


func add_potion():
	potions += 1
	hud.update_potion_label(potions)


func reset_potions():
	potions = 0
	hud.update_potion_label(potions)
	
