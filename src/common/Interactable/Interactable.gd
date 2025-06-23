extends CollisionObject3D

class_name Interactable

signal interacted(body)

## Message that will appear floating near the object when it's a candidate for interaction
@export var prompt_message: String = "Interact"

## Enable or disable interacting with this object. Will also hide its label.
@export var is_enabled: bool = true

## Action name to use for interacting with this object.
## You can use this to change the key that needs to be pressed. The prompt will update accordingly to display the exact key.
@export var interact_action_name: String = "interact"

## Once - pressing and holding the interaction key is effective only once - holding has no effect
##
## Continuous - press and hold to interact repeatedly
@export_enum("Once", "Continuous") var interaction_mode: String = "Once"

@onready var label: Label3D = $Label3D

var _key_name: String

func _ready() -> void:
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_key_name = _get_key()
	
func interact(body):
	interacted.emit(body)
	
func get_prompt() -> String:
	return prompt_message + "\n[" + _key_name + "]"

func hide_label():
	label.text = ""
	
func show_label():
	label.text = get_prompt()

func _get_key() -> String:
	var key_name := ""
	for action in InputMap.action_get_events(self.interact_action_name):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	return key_name
