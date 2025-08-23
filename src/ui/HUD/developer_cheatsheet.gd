extends Control

class_name DeveloperCheatsheet

@onready var background: ColorRect = $Background
@onready var title_label: Label = $Background/VBoxContainer/MarginContainer/VBoxContainer2/TitleLabel
@onready var content_container: VBoxContainer = $Background/VBoxContainer/MarginContainer/VBoxContainer2/ContentContainer

var developer_actions: Array[String] = [
	"dev_free_cursor",
	"dev_third_person_camera", 
	"dev_kill",
	"dev_respawn"
]

var action_descriptions: Dictionary = {
	"dev_free_cursor": "Free Cursor",
	"dev_third_person_camera": "Toggle 3rd Person Camera",
	"dev_kill": "Kill Player",
	"dev_respawn": "Respawn Player"
}

func _ready() -> void:
	hide()
	_setup_cheatsheet()

func _setup_cheatsheet() -> void:
	# Clear existing content
	for child in content_container.get_children():
		child.queue_free()
	
	# Add each developer action with its keybind
	for action_name in developer_actions:
		if InputMap.has_action(action_name):
			var keybind_text = _get_action_keybind(action_name)
			var description = action_descriptions.get(action_name, action_name)
			
			if keybind_text != "":
				_add_keybind_entry(keybind_text, description)

func _add_keybind_entry(keybind: String, description: String) -> void:
	var entry_container = HBoxContainer.new()
	
	# Key label (styled as a key/button)
	var key_label = Label.new()
	key_label.text = keybind
	key_label.add_theme_font_size_override("font_size", 12)
	key_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Separator
	var separator = Label.new()
	separator.text = " - "
	separator.add_theme_font_size_override("font_size", 12)
	separator.add_theme_color_override("font_color", Color.WHITE)
	
	# Description label
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color.WHITE)
	
	entry_container.add_child(key_label)
	entry_container.add_child(separator)
	entry_container.add_child(desc_label)
	
	content_container.add_child(entry_container)

func _get_action_keybind(action_name: String) -> String:
	if Engine.is_editor_hint(): 
		return "Alt+Key"
	
	var key_text := ""
	var events = InputMap.action_get_events(action_name)
	
	for event in events:
		if event is InputEventKey:
			key_text = event.as_text_physical_keycode()
			break
	
	return key_text

func show_cheatsheet() -> void:
	# Refresh keybinds in case they changed
	_setup_cheatsheet()
	show()

func hide_cheatsheet() -> void:
	hide()