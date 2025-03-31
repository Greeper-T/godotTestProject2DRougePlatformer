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
var resources : Array[Resource] = []


func _ready():
	var hud_nodes = get_tree().get_nodes_in_group("hud")
	print("HUD nodes found:", hud_nodes)
	hud = get_tree().get_first_node_in_group("hud")
	gui = get_tree().get_first_node_in_group("gui")
	load_resources_from_folder("res://assets/scripts/itemScripts/itemResources/")
	for resource in resources:
		if resource is Resource:
			print("name: ", resource.itemName, "    type: ", resource.type)
	

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
	var dir = DirAccess.open("res://assets/scripts/itemScripts/itemResources/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(path + file_name)
				if resource is Resource:
					resources.append(resource)
			file_name = dir.get_next()
	else:
			print("Error: Could not open folder at path:", path)


func add_item_to_inventory(new_item: Item) -> bool:
	var inventory = get_tree().get_first_node_in_group("inventory_slots")
	for slot in inventory.get_children():
		if slot.item == null:
			slot.item = new_item  # Assign the item to an open slot
			return true
	return false  # Inventory full

func spawn_random_item(position: Vector2):
	var item = get_random_item()  # Get a random item
	if item:
		var item_scene = preload("res://assets/scenes/items/PickUpItem.tscn").instantiate()
		item_scene.item = item
		item_scene.global_position = position
		get_tree().current_scene.add_child(item_scene)

func get_random_item() -> Item:
	var weighted_items = []
	for resource in resources:
		match resource.type:
			Item.Type.COMMON:
				weighted_items.append(resource)  # Higher probability
			Item.Type.UNCOMMON:
				weighted_items.append(resource)  # Less frequent
			Item.Type.RARE:
				weighted_items.append(resource)  # Rare
			Item.Type.LEGENDARY:
				weighted_items.append(resource)  # Super rare
	# Pick a random item
	if weighted_items.size() > 0:
		return weighted_items[randi() % weighted_items.size()]
	return null  # No item found
