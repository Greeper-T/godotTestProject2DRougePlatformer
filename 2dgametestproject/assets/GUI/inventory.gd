extends Control


var items_to_load :=[
	"res://assets/scripts/itemScripts/speedSoup.tres",
	
]



func _ready():
	for i in 24:
		var slot := InventorySlot.new()
	for i in items_to_load.size():
		var item = InventoryItem.new
