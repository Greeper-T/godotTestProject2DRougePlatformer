extends Area2D

@export var item: Item  # Assign an item resource in the editor
@onready var sprite: Sprite2D = $Sprite2D  
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  
@onready var pickup_label: Label = $Control/pickup_label

const MAX_ITEM_SIZE := Vector2(32, 32)  

var player_in_range = false

func _ready():
	# Assign a random item if none is set
	if item == null:
		item = GameManager.get_random_item()
		if item == null:
			print("Error: No items available in GameManager!")
			queue_free()

	if item:
		sprite.texture = item.texture
		resize_sprite()
	else:
		print("Warning: No item assigned to PickUpItem!")

	# Update pickup label with the correct keybind
	update_pickup_label()
	pickup_label.hide()  # Hide label initially

func resize_sprite():
	if sprite.texture:
		var tex_size = sprite.texture.get_size()
		var scale_factor = min(MAX_ITEM_SIZE.x / tex_size.x, MAX_ITEM_SIZE.y / tex_size.y)
		sprite.scale = Vector2(scale_factor, scale_factor)

		if collision_shape.shape is RectangleShape2D:
			collision_shape.shape.size = MAX_ITEM_SIZE

func _on_body_entered(body: Node2D) -> void:
	player_in_range = true
	update_pickup_label()  # Ensure the label reflects the latest keybind
	pickup_label.show()  
	print("Player in range. Press the correct key to pick up.")

func _on_body_exited(body: Node2D) -> void:
	player_in_range = false  
	pickup_label.hide()  
	print("Player left range.")

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("Interact"):
		pick_up()

func pick_up():
	if player_in_range and item:
		var added = GameManager.add_item_to_inventory(item)
		if added:
			print("Picked up:", item.itemName)

			# 🔹 Count the item in player stats
			if !item.itemCounted:
				PlayerData.calcItem(item)
				item.itemCounted = true

			queue_free()
		else:
			print("Inventory full, cannot pick up item.")

func update_pickup_label():
	if pickup_label:
		var events = InputMap.action_get_events("Interact")
		if events.size() > 0:
			pickup_label.text = "Press '" + events[0].as_text().trim_suffix(" (Physical)") + "' to pick up"
		else:
			pickup_label.text = "Press 'Unknown' to pick up"
	else:
		print("Error: pickup_label is not found!")
