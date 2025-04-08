extends Control


func ItemPopup(slot: Rect2i, item):
	if item != null:
		set_value(item)
		%ItemPopup.size = Vector2i.ZERO  # Optional: if resizing dynamically

	# Set a fixed position for the popup
	var fixed_position = Vector2i(723, 163)  # Adjust these values to your layout

	# Optionally add some size for safety
	var popup_size = Vector2i(200, 100)  # Or calculate from %ItemPopup.size if needed

	%ItemPopup.popup(Rect2i(fixed_position, popup_size))



func HideItemPopup():
	%ItemPopup.hide()


func set_value(item : Item):
	%Name.text = item.itemName
	%AmtNum.text = str(item.itemAmt)
	%Rarity.text = str(item.type)
	%DescInfo.text = item.itemDescription
