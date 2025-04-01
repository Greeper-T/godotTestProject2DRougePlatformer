extends Area2D

@export var item: Item  # Assign an item resource in the editor
@onready var sprite: Sprite2D = $Sprite2D  # Reference to the sprite

func _ready():
	if item:
		sprite.texture = item.texture  # Display correct item texture

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		var added = GameManager.add_item_to_inventory(item)
		if added:
			queue_free()  # Remove item after pickup
