extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	var x = PlayerData.maxHp
	$hp_bar.max_value = get_node("../player").maxHp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$hp_bar.value = get_node("../player").hp
