extends Control


var items_to_load :=[
	"res://assets/scripts/itemScripts/speedSoup.tres",
	
]



func _ready():
	for i in 24:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(32, 32))
		%Grid.add_child(slot)
	for i in items_to_load.size():
		var item = InventoryItem.new
		item.init(load(items_to_load[i]))
		%Grid.get_child(i).add_child(item)
