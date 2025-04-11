extends CanvasLayer
class_name GUI

@export var healthLabel : Label
var hidden = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$hp_bar.max_value = PlayerData.maxHp



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$hp_bar.max_value = PlayerData.maxHp
	$hp_bar.value = PlayerData.hp
	updateHealthLabel()



func updateHealthLabel():
	healthLabel.text = "" + str($hp_bar.value) + "/" + str($hp_bar.max_value)
	

func updateMoneyLabel():
	healthLabel.text = "" + "AMT" +"X"
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
		if hidden:
			hidden = false
			%Inventory.show()
		else:
			hidden = true
			%Inventory.hide()
