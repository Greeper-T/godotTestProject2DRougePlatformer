extends PanelContainer


# Helper function to get the Popups node from the group
func get_popups():
	var popups = get_tree().get_nodes_in_group("Popups")
	print("Found Popups nodes:", popups) # Debugging
	return null


func _on_mouse_entered() -> void:
	var popups = get_tree().get_first_node_in_group("Popups")
	popups.ItemPopup(null, null)

func _on_mouse_exited() -> void:
	var popups = get_tree().get_first_node_in_group("Popups")
	popups.HideItemPopup()
