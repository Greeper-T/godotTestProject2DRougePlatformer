extends Node

var pauseScreen = preload("res://assets/UI Settings/inputSettings/inputSetting.tscn")
var currentArea = 1
var areaPath = "res://assets/scenes/playable/"

var potions = 0
#var area_container : Node2D
#var player : PlayerController
var hud : HUD



func _ready():
	var hud_nodes = get_tree().get_nodes_in_group("hud")
	print("HUD nodes found:", hud_nodes)
	hud = get_tree().get_first_node_in_group("hud")
	randomize()

#func _initialize_hud():
	#hud = get_tree().get_first_node_in_group("hud")
	

func nextLevel():
	hud = get_tree().get_first_node_in_group("hud")
	currentArea += 1
	var fullPath = areaPath + "area_" + str(currentArea) + ".tscn"

	get_tree().change_scene_to_file(fullPath)
	print_debug("entered portal")
	print(hud)
	hud.update_potion_label(potions)


func set_up_area():
	reset_potions()


func add_potion():
	hud = get_tree().get_first_node_in_group("hud")
	potions += 1
	hud.update_potion_label(potions)
 
func usePotion():
	hud = get_tree().get_first_node_in_group("hud")
	if 	potions > 0:
		potions -=1
		hud.update_potion_label(potions)
		return true
	return false


func reset_potions():
	hud = get_tree().get_first_node_in_group("hud")
	potions = 0
	print(potions)
	hud.update_potion_label(potions)
	
func hudUpdate():
	hud = get_tree().get_first_node_in_group("hud")
	hud.update_potion_label(potions)
