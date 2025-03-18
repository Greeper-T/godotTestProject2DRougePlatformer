extends PanelContainer

@export var item: Item = null:
	set(value):
		item = value
		if value != null:
			PlayerData.calcItem(value)
			$TextureRect.texture = value.texture


func _on_mouse_entered() -> void:
	if item == null:
		return
	
	Popups.ItemPopup(Rect2i( Vector2i(global_position), Vector2i(size)), item)

func _on_mouse_exited() -> void:
	Popups.HideItemPopup()
