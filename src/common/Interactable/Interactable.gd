extends CollisionObject3D

class_name Interactable

signal interacted(body)

@export var displays_prompt: bool = true

## Message that will appear floating near the object when it's a candidate for interaction
@export var prompt_message: String = ""

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

@onready var label: Label3D = $Label3D

var _key_name: String
var _timeout_left: float = 0.0

func _ready() -> void:
	self.collision_layer = Bits.from([Layer.Interactables])
	self.label.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Make the label always face the Player
	self._key_name = _get_key()
	self.label.text = get_prompt()
	hide_label()

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
	return prompt_message + "\n[" + _key_name + "]"

func hide_label():
	label.hide()
	
func show_label():
	label.show()
	
func set_prompt(new_prompt: String):
	prompt_message = new_prompt
	self.label.text = get_prompt()

## Called once to get the key assigned for interacting with this object
func _get_key() -> String:
	var key_name := ""
	for action in InputMap.action_get_events(self.interact_action_name):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	return key_name
