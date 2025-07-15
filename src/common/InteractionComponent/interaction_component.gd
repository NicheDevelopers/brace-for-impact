@tool
extends Area3D

class_name InteractionComponent

signal interacted(body)

@export var _displays_prompt: bool = true

@export var prompt_message_new: String = ""

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

@onready var parent = get_parent()
@onready var label: Label3D
@onready var hitbox: CollisionShape3D

var _key_name: String
var _timeout_left: float = 0.0

var label_initial_local_transform: Vector3

func _ready() -> void:
	_key_name = _get_key()
	
	label = get_node_or_null("Label3D")
	hitbox = get_node_or_null("CollisionShape3D")
	
	if not hitbox:
		var parent_hitbox = parent.get_node_or_null("CollisionShape3D")
		if parent_hitbox:
			hitbox = parent_hitbox.duplicate()
			add_child(hitbox)
		elif not Engine.is_editor_hint():
			push_error("No viable CollisionShape3D for InteractionComponent")
	
	if label != null:
		label_initial_local_transform = label.transform.origin
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Make the label always face the Player
		label.text = get_prompt()
	
	if not Engine.is_editor_hint():
		if label != null: hide_label()
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

func _physics_process(_delta: float) -> void:
	if not label: return
	label.global_position = self.global_position + label_initial_local_transform

func get_prompt() -> String:
	if not _displays_prompt:
		return ""
	return prompt_message_new + "\n[" + _key_name + "]"

func hide_label():
	if label == null: return
	label.hide()

func show_label():
	if label == null: return
	label.show()

func set_prompt(new_prompt: String):
	if label == null: return
	prompt_message_new = new_prompt
	self.label.text = get_prompt()

## Called once to get the key assigned for interacting with this object
func _get_key() -> String:
	if Engine.is_editor_hint(): return "key"
	
	var key_name := ""
	for action in InputMap.action_get_events(self.interact_action_name):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	return key_name
