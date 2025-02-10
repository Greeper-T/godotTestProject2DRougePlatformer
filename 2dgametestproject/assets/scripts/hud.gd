extends Control
class_name HUD

@export var potion_label : Label
@export var item_label : Label






func update_potion_label(number : int):
	potion_label.text = "x " + str(number)
