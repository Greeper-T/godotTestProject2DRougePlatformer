extends Node

var pauseScreen = preload("res://assets/UI Settings/inputSettings/inputSetting.tscn")
var currentArea = 1
var areaPath = "res://assets/scenes/playable/"

var potions = 0
#var area_container : Node2D
#var player : PlayerController
var hud : HUD
var gui : GUI
var hpBar : HPBar
var resource : Array[Resource] = []


func _ready():
	var hud_nodes = get_tree().get_nodes_in_group("hud")
	print("HUD nodes found:", hud_nodes)
	hud = get_tree().get_first_node_in_group("hud")
	gui = get_tree().get_first_node_in_group("gui")
	

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


# Function to load all .tres files from a folder
func load_resources_from_folder(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(path + file_name)
			if resource is ItemResource:
					resources.append(resource)
			file_name = dir.get_next()
	else:
			print("Error: Could not open folder at path:", path)
