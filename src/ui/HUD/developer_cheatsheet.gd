extends Control

class_name DeveloperCheatsheet

@onready var background: ColorRect = $Background
@onready var title_label: Label = $Background/TitleLabel
@onready var content_container: VBoxContainer = $Background/ScrollContainer/ContentContainer

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
	for child in content_container.get_children():
		child.queue_free()
	
	var actions = InputMap.get_actions()
	
	for action in actions:
		if not action.begins_with("dev"): continue
		
		var keybind_text = _get_action_keybind(action)
		var description = action_descriptions.get(action, action)
		
		if keybind_text != "":
			_add_keybind_entry(keybind_text, description)

func _add_keybind_entry(keybind: String, description: String) -> void:
	var entry_container = HBoxContainer.new()
	
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
	_setup_cheatsheet()
	show()

func hide_cheatsheet() -> void:
	hide()
