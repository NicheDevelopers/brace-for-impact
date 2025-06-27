extends Control

@onready var action_list = $Panel/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var input_button_scene = preload("res://src/UI/Settings/Input Settings/keybind_button.tscn")
@onready var notification = $Notification

var is_remapping = false
var action_to_remap = null
var remapped_button = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTracker.set_current_scene(SceneTracker.scenes.INPUT_SETTINGS)
	_create_action_list()
	
func _create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
		
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("ActionLabel")
		var key_label = button.find_child("KeyLabel")
		action_label.text = action
		
		var events = InputMap.action_get_events(action)
		if events:
			key_label.text = events[0].as_text()
		else:
			key_label.text = ""
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapped_button = button
		button.find_child("KeyLabel").text = "Listening for input..."

func _input(event) -> void:
	if is_remapping:
		if (event is InputEventKey or (event is InputEventMouseButton && event.pressed)):
			var captured_event = event.as_text()
			var already_in_use = false
			for action in InputMap.get_actions():
				if action.begins_with("ui_"):
					continue
				var events = InputMap.action_get_events(action)
				var keybind = events[0].as_text()
				if keybind == event.as_text() and action != remapped_button.find_child("ActionLabel").text:
					notification._show(event.as_text() + " is already used by action \"" + action + "\".")
					var former_keybind = InputMap.action_get_events(
						remapped_button.find_child("ActionLabel").text
					)[0].as_text()
					remapped_button.find_child("KeyLabel").text = former_keybind
					already_in_use = true
			if not already_in_use:
				InputMap.action_erase_events(action_to_remap)
				InputMap.action_add_event(action_to_remap, event)
				remapped_button.find_child("KeyLabel").text = event.as_text()
			is_remapping = false
			action_to_remap = null
			remapped_button = null
			accept_event()

func _on_back_pressed() -> void:
	SceneTracker.go_to_previous_scene()

func _on_reset_pressed() -> void:
	_create_action_list()
