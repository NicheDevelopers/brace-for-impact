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

@export var prompt_message: String = ""

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
@export_enum("Once", "Continuous") var instant_interaction_mode: String = "Once"

## Restricts the frequency of possible interactions
@export var instant_interaction_timeout: float = 0.0

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

var _current_users: Array[Variant] = []

var label_initial_local_transform: Vector3

func _ready() -> void:
	_key_name = _get_key()
	
	label = get_node_or_null("Label3D")
	hitbox = get_node_or_null("CollisionShape3D")
	
	if not label:
		push_error(name + " initialized without a Label3D")
	
	if not hitbox:
		var parent_hitbox = parent.get_node_or_null("CollisionShape3D")
		if parent_hitbox:
			hitbox = parent_hitbox.duplicate()
			add_child(hitbox)
		elif not Engine.is_editor_hint():
			push_error(
				"No viable CollisionShape3D for InteractionComponent: ",
				get_tree_string_pretty()
			)
	if label != null:
		label_initial_local_transform = label.transform.origin
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Make the label always face the Player
		label.pixel_size = 0.002
		label.no_depth_test = true # Make the label always render on top, so it won't be obstructed by other objects
		label.fixed_size = true # Always stays the same size, no matter the distance
		label.text = get_prompt()
	
	if not Engine.is_editor_hint():
		if label != null: hide_label()
		self.collision_layer = Bits.from([Layer.Interactables])
		self.collision_mask = Bits.from([Layer.World, Layer.Interactables])
		interaction_stopped.connect(_on_interaction_stopped)

func interact(body):
	if not can_interact_with(body):
		return
	
	_start_interaction(body)
	if interaction_type == "Instant":
		_timeout_left = instant_interaction_timeout

## Whether this [InteractionComponent] is busy, i.e.
## is of type 'Lasting' and the number of ongoing interactions
## has reached [member max_interactions_at_a_time]
func is_busy():
	if interaction_type == "Lasting":
		if _current_users.size() >= max_interactions_at_a_time:
			return true
	return false

## Whether this [InteractionComponent] can interact
## with the provided [param body].
func can_interact_with(body: Variant):
	if not is_interaction_enabled:
		return false
	if interaction_type == "Instant" and _timeout_left > 0.0:
		return false
	if interaction_type == "Lasting":
		if is_busy():
			return false
		if _current_users.has(body):
			return false
	return true

## Returns a list of bodies who are actively in an
## interaction with this [InteractionComponent].
## Always an empty array for the 'Instant' type
## [InteractionComponent]s
func get_current_users() -> Array[Variant]:
	return _current_users

func _start_interaction(body):
	if interaction_type == "Lasting":
		_current_users.append(body)
	
	interacted.emit(body)

func _on_interaction_stopped(body):
	_current_users = _current_users.filter(func(user):
		return user != body
	)

## Handles counting down the potential interaction timeout
func _process(delta: float) -> void:
	if _timeout_left > 0:
		_timeout_left -= delta

func _physics_process(_delta: float) -> void:
	if not label: return
	if Engine.is_editor_hint(): return
	label.global_position = self.global_position + label_initial_local_transform

func get_prompt() -> String:
	if not _displays_prompt:
		return ""
	return prompt_message + "\n[" + _key_name + "]"

func hide_label():
	if label == null: return
	label.hide()

func show_label():
	if label == null: return
	label.show()

func set_prompt(new_prompt: String):
	if label == null: return
	prompt_message = new_prompt
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
