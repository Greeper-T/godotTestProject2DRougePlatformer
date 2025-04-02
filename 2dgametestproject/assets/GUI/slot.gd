extends PanelContainer

#@export var item: Item = null:
	#set(value):
		#item = value
		#if value != null:
			#if value.itemCounted != true:
				#PlayerData.calcItem(value)
				#value.itemCounted = true
			#$TextureRect.texture = value.texture
			


@export var item: Item = null:
	set(value):
		item = value
		if value != null:
			if value.itemCounted != true:
				PlayerData.calcItem(value)
				value.itemCounted = true
			$TextureRect.texture = value.texture
		update_display()

@onready var texture_rect: TextureRect = $TextureRect  # Make sure this node exists

func update_display():
	if texture_rect == null:
		print("Error: TextureRect not found in slot!")  # Debugging
		return
		
	if item:
		texture_rect.texture = item.texture  # Set texture if item exists
	else:
		texture_rect.texture = null  # Clear if no item


func _on_mouse_entered() -> void:
	if item == null:
		return
	
	Popups.ItemPopup(Rect2i( Vector2i(global_position), Vector2i(size)), item)

func _on_mouse_exited() -> void:
	Popups.HideItemPopup()
	
	
