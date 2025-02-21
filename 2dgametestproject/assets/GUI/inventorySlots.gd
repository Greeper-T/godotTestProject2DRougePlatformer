class_name InventorySlot
extends PanelContainer

@export var type: ItemData.Type
var player

func _ready():
	player = get_tree().get_nodes_in_group("Player")

func init(t: ItemData.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is InventoryItem:
		if type == ItemData.Type.MAIN:
			if get_child_count() == 0:
				return true
			else:
				if type == data.get_parent().type:
					return true
				return get_child(0).data.type == data.data.type
		else:
			return data.data.type == type
	return false

func _drop_data(_at_postion:Vector2, data: Variant) -> void:
	if get_child_count() > 0:
		var item := get_child(0)
		player[0].damage -= item.data.itemDamage
		player[0].defense -= item.data.itemDefense
		if item == data:
			return
		item.reparent(data.get_parent())
		if type != ItemData.Type.MAIN:
			player[0].damage += item.data.itemDamage
			player[0].defense += item.data.itemDefense
		else:
			player[0].damage += item.data.itemDamage
			player[0].defense += item.data.itemDefense
		data.reparent(self)

		
