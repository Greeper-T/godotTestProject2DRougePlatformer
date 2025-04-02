extends Area2D

@export var item: Item  # Assign an item resource in the editor
@onready var sprite: Sprite2D = $Sprite2D  # Reference to the sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  # Reference to collision shape

const MAX_ITEM_SIZE := Vector2(32, 32)  # Adjust as needed

var player_in_range: PlayerController = null  # Store player when in range

func _ready():
	# If no item is assigned in the editor, pick a random one from GameManager
	if item == null:
		item = GameManager.get_random_item()
		if item == null:
			print("Error: No items available in GameManager!")
			queue_free()  # Prevent empty pickups
	
	# Assign the texture and resize the sprite
	if item:
		sprite.texture = item.texture
		resize_sprite()
	else:
		print("Warning: No item assigned to PickUpItem!")

func resize_sprite():
	if sprite.texture:
		var tex_size = sprite.texture.get_size()
		var scale_factor = min(MAX_ITEM_SIZE.x / tex_size.x, MAX_ITEM_SIZE.y / tex_size.y)
		sprite.scale = Vector2(scale_factor, scale_factor)

		# Resize collision shape to fit item
		if collision_shape.shape is RectangleShape2D:
			collision_shape.shape.size = MAX_ITEM_SIZE

# Detect when player enters range
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = body  # Store player reference
		print("Player in range. Press 'E' to pick up.")

# Detect when player leaves range
func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = null  # Clear player reference
		print("Player left range.")

# Handle key press for picking up item
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("Interact"):  # Press "E"
		pick_up()

# Pickup function
func pick_up():
	if player_in_range and item:
		var added = GameManager.add_item_to_inventory(item)
		if added:
			print("Picked up:", item.itemName)
			queue_free()  # Remove item after pickup
		else:
			print("Inventory full, cannot pick up item.")
