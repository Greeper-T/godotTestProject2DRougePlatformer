extends Area2D

@export var item: Item  # Assign an item resource in the editor
@onready var sprite: Sprite2D = $Sprite2D  # Reference to the sprite

func _ready():
	if item:
		sprite.texture = item.texture  # Ensure the correct texture is displayed
	else:
		print("Warning: No item assigned to PickUpItem!")

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		if item:  # Ensure there's an item to pick up
			var added = GameManager.add_item_to_inventory(item)
			if added:
				print("Picked up item:", item.itemName)
				queue_free()  # Remove item after pickup
			else:
				print("Inventory full, cannot pick up item.")
