extends Control

@onready var button = preload("res://assets/UI Settings/inputSettings/input_button.tscn")

@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/actionList

var isRemapping = false
var actionToRemap = null
var remappingButton = null

var gamePaused = false

var inputActions = {
	"jump": "Jump",
	"moveLeft": "Move Left",
	"moveRight": "Move Right",
	"moveDown": "Move Down",
	"sprint": "Sprint",
	"fireBullet": "Fire Wepon",
	"heal": "Use Health Potion",
	"dash": "Dash",
	"switch": "Switch Wepon",
	"Interact": "Interact",
}

func _ready() -> void:
	createActionList()

func createActionList():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in inputActions:
		var buttons = button.instantiate()
		var actionLabel = buttons.find_child("LabelAction")
		var inputLabel = buttons.find_child("LabelInput")
		
		actionLabel.text = inputActions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
		
		action_list.add_child(buttons)
		buttons.pressed.connect(_on_input_button_pressed.bind(buttons, action))

func _on_input_button_pressed(buttons, action):
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingButton = buttons
		buttons.find_child("LabelInput").text = "Press Key To Change Bind..."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		gamePaused = !gamePaused
		if gamePaused:
			Engine.time_scale = 0
			#self.setVisibility()
		else:
			Engine.time_scale = 1
			#self.setVisibility()
	if isRemapping:
		if event is InputEventKey or event is InputEventMouseButton:
			InputMap.action_erase_events(actionToRemap)
			InputMap.action_add_event(actionToRemap, event)
			updateActionList(remappingButton, event)
			
			isRemapping = false
			actionToRemap = null
			remappingButton = null
			
			accept_event()

func updateActionList(buttons, event):
	buttons.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

func setVisibility():
	visible = !visible


func _on_reset_button_pressed() -> void:
	createActionList()


func _on_title_screen_pressed() -> void:
	Engine.time_scale = 1
	GameManager.backToMenu()
