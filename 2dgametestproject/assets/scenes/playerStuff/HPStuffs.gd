extends CanvasLayer
class_name HPBar

@export var healthLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	$hp_bar.max_value = get_node("../player").maxHp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$hp_bar.max_value = get_node("../player").maxHp
	$hp_bar.value = get_node("../player").hp
	updateHealthLabel()



func updateHealthLabel():
	healthLabel.text = "" + str($hp_bar.value) + "/" + str($hp_bar.max_value)
	
	
