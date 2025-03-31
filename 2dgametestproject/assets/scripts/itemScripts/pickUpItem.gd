exextends Area2D

@export var item: Item  # Assign a random item when spawned
@onready var sprite: Sprite2D = $Sprite2D  # Reference to sprite component

func _ready():
	if item:
		sprite.texture = item.texture  # Display item texture

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		var added = GameManager.add_item_to_inventory(item)
		if added:
			queue_free()  # Remove the item after pickup
