@tool
extends Area3D

class_name InteractionComponent

## A signal emitted when an object of any [member interaction_type]
## is interacted with
signal interacted(body)

## A signal meant to be emmited for [InteractionComponent]s
## set to type 'Lasting', which means the interaction has ended.
## The responsibility to call this signal at the right moment
## is on the object, [InteractionComponent] just reacts to it
signal interaction_stopped(body)

@export var _displays_prompt: bool = true

@export var prompt_message_new: String = ""

## Enable or disable interacting with this object. Will also hide its label.
@export var is_interaction_enabled: bool = true

## Action name to use for interacting with this object.
## You can use this to change the key that needs to be pressed. The prompt will update accordingly to display the exact key.
@export var interact_action_name: String = "interact"

## Instant[br]
## - interacting means emitting the [signal interacted] signal
## [br][br]
## Lasting[br]
## - interacting means emitting the [signal interacted] signal
## and is tracked until [signal interaction_stopped] is received. This
## means that the [param body]ies who interacted are stored
## and counted (and their number cannot exceed
## [member max_interactions_at_a_time])
@export_enum("Instant", "Lasting") var interaction_type: String = "Instant"

@export_group("Instant Interactions")

## Once - pressing and holding the interaction key is effective only once - holding has no effect
##
## Continuous - press and hold to interact repeatedly
@export_enum("Once", "Continuous") var interaction_mode: String = "Once"

## Restricts the frequency of possible interactions
@export var interaction_timeout: float = 0.0

@export_group("Lasting Interactions")
## Defines how many players can interact with the object at once.
## If this many players interact, the InteractableComponent will become busy
## and not accept any new interactions until some of the ongoing ones stop
@export var max_interactions_at_a_time: int = 1

@onready var parent = get_parent()
@onready var label: Label3D
@onready var hitbox: CollisionShape3D

var _key_name: String
var _timeout_left: float = 0.0

var _ongoing_interactions: int = 0

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
		interaction_stopped.connect(_on_interaction_stopped)

func interact(body):
	if _timeout_left > 0.0:
		return
	if is_busy():
		return
	
	_start_interaction(body)
	_timeout_left = interaction_timeout

## Whether this [InteractionComponent] is busy, i.e.
## is of type 'Lasting' and the number of ongoing interactions
## has reached [member max_interactions_at_a_time]
func is_busy():
	if interaction_type == "Lasting":
		if _ongoing_interactions >= max_interactions_at_a_time:
			return true
	return false

func _start_interaction(body):
	if interaction_type == "Lasting":
		_ongoing_interactions += 1
		if is_busy():
			is_interaction_enabled = false
	
	interacted.emit(body)

func _on_interaction_stopped(body):
	_ongoing_interactions -= 1
	if not is_busy():
		is_interaction_enabled = true

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
