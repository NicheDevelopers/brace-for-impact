@tool
extends Area3D

class_name InteractionComponent

signal interacted(body)

@export var displays_prompt: bool = true:
	set(v):
		displays_prompt = v
		notify_property_list_changed()


## Message that will appear floating near the object when it's a candidate for interaction
var _prompt_message: String = ""

## Enable or disable interacting with this object. Will also hide its label.
@export var is_interaction_enabled: bool = true

## Action name to use for interacting with this object.
## You can use this to change the key that needs to be pressed. The prompt will update accordingly to display the exact key.
@export var interact_action_name: String = "interact"

## Restricts the frequency of possible interactions
@export var interaction_timeout: float = 0.0

## Once - pressing and holding the interaction key is effective only once - holding has no effect
##
## Continuous - press and hold to interact repeatedly
@export_enum("Once", "Continuous") var interaction_mode: String = "Once"

@export var show_string_setting_ok := false:
	set(v):
		show_string_setting_ok = v
		notify_property_list_changed()

var _string_setting := "hello"

func _get_property_list() -> Array[Dictionary]:
	var properties = []
	if displays_prompt:
		properties.append({"name": "prompt_message", "type": TYPE_STRING})
	if show_string_setting_ok:
		properties.append({"name": "string_setting", "type": TYPE_STRING})

	return properties

func _get(property):
	if property == "prompt_message":
		return _prompt_message
	if property == "string_setting":
		return _string_setting
	return null

func _set(property, value):
	if property == "prompt_message":
		_prompt_message = value
		return true
	if property == "string_setting":
		_string_setting = value
		return true
	return false

@onready var parent = get_parent()
@onready var label: Label3D
@onready var hitbox: CollisionShape3D

var _key_name: String
var _timeout_left: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_key_name = _get_key()
	
	label = $Label3D
	hitbox = $CollisionShape3D
	if label != null:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Make the label always face the Player
		label.text = get_prompt()
		hide_label()
	
	self.collision_layer = Bits.from([Layer.Interactables])
	self.collision_mask = Bits.from([Layer.World, Layer.Interactables])


func interact(body):
	if _timeout_left > 0.0:
		return
		
	interacted.emit(body)
	_timeout_left = interaction_timeout

## Handles counting down the potential interaction timeout
func _process(delta: float) -> void:
	if _timeout_left > 0:
		_timeout_left -= delta
	
func get_prompt() -> String:
	if not displays_prompt:
		return ""
	return _prompt_message + "\n[" + _key_name + "]"

func hide_label():
	if label == null: return
	label.hide()
	
func show_label():
	if label == null: return
	label.show()
	
func set_prompt(new_prompt: String):
	if label == null: return
	_prompt_message = new_prompt
	self.label.text = get_prompt()

## Called once to get the key assigned for interacting with this object
func _get_key() -> String:
	var key_name := ""
	for action in InputMap.action_get_events(self.interact_action_name):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	return key_name
