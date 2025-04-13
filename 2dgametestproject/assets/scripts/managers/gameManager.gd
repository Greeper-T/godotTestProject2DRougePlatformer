extends Node

var pauseScreen = preload("res://assets/UI Settings/inputSettings/inputSetting.tscn")
var currentArea = 1
var currentPhase = 0
var areaPath = "res://assets/scenes/playable/"
var shop = "res://assets/scenes/playable/Shop.tscn"

var playerScene = preload("res://assets/scenes/playerStuff/player.tscn")

var potions = 20
var hud: HUD
var gui: GUI
var resources: Array[Item] = []  # Holds Item resources

func _ready():
	hud = get_tree().get_first_node_in_group("hud")
	gui = get_tree().get_first_node_in_group("gui")
	load_resources_from_folder("res://assets/scripts/itemScripts/itemResources/")

	if resources.is_empty():
		print("Warning: No items loaded into GameManager!")

# -- Level Management --
func nextLevel():
	hud = get_tree().get_first_node_in_group("hud")
	currentArea += 1
	if currentPhase == 0:
		get_tree().change_scene_to_file(shop)
		currentPhase = 1
	elif currentPhase == 1:
		get_tree().change_scene_to_file("res://assets/scenes/playable/area_4.tscn")
		currentPhase = 2
	elif currentPhase == 2:
		get_tree().change_scene_to_file("res://assets/scenes/playable/area_0.tscn")
		currentPhase = 0
	var fullPath = areaPath + "area_" + str(currentArea) + ".tscn"
	print_debug("Entered portal to:", fullPath)
	hud.update_potion_label(potions)

func set_up_area():
	reset_potions()

# -- Potion Handling --
func add_potion():
	if hud:
		potions += 1
		hud.update_potion_label(potions)

func usePotion():
	if hud and potions > 0:
		potions -= 1
		hud.update_potion_label(potions)
		return true
	return false

func reset_potions():
	if hud:
		potions = 0
		hud.update_potion_label(potions)

func hudUpdate():
	hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_potion_label(potions)

func add_item_to_inventory(new_item: Item) -> bool:
	gui = get_tree().get_first_node_in_group("gui")
	if gui == null:
		print("Error: GUI not found!")
		return false
	
	var inventory = gui.get_node_or_null("%Inventory")
	if inventory == null:
		print("Error: Inventory not found!")
		return false
	
	var grid_container = inventory.get_node_or_null("GridContainer")
	if grid_container == null:
		print("Error: GridContainer not found inside Inventory!")
		return false

	# Check for duplicate item
	for slot in grid_container.get_children():
		if slot.item != null and slot.item.itemId == new_item.itemId:
			# Duplicate found — stack it
			slot.item.itemAmt += new_item.itemAmt

			# Add *only* the new amount to stats
			var tempItem := new_item.duplicate()
			tempItem.itemAmt = new_item.itemAmt
			PlayerData.calcItem(tempItem)

			slot.update_display()
			print("Stacked item:", new_item.itemName, "New amt:", slot.item.itemAmt)
			return true

	# If not already in inventory, place in an empty slot
	for slot in grid_container.get_children():
		if slot.item == null:
			slot.item = new_item
			slot.update_display()
			print("Added new item:", new_item.itemName)
			return true

	print("Inventory full!")
	return false

# -- Random Item Spawning --
func spawn_random_item(position: Vector2):
	var item = get_random_item()
	if item:
		var item_scene = preload("res://assets/scenes/items/PickUpItem.tscn").instantiate()
		item_scene.item = item
		item_scene.global_position = position
		get_tree().current_scene.add_child(item_scene)

func get_random_item() -> Item:
	if resources.is_empty():
		print("Error: No items found in resources!")
		return null
	
	var weighted_items = []
	for resource in resources:
		match resource.type:
			Item.Type.COMMON:
				weighted_items.append(resource)  # Higher probability
			Item.Type.UNCOMMON:
				if randi() % 100 < 30:  # 30% chance
					weighted_items.append(resource)
			Item.Type.RARE:
				if randi() % 100 < 10:  # 10% chance
					weighted_items.append(resource)
			Item.Type.LEGENDARY:
				if randi() % 100 < 2:  # 2% chance
					weighted_items.append(resource)

	if weighted_items.size() > 0:
		return weighted_items[randi() % weighted_items.size()]

	return resources[randi() % resources.size()]  # Fallback item

# -- Resource Loading --
func load_resources_from_folder(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(path + "/" + file_name)
				if resource is Item:  # Ensure only Item resources are added
					resources.append(resource)
			file_name = dir.get_next()
	else:
		print("Error: Could not open folder at path:", path)
