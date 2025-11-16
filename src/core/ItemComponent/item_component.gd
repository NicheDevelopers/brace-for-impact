@tool
extends InteractionComponent

class_name ItemComponent

signal used(body)

## Enable or disable using this item while held in hand.
@export var is_usage_enabled: bool = true

## Restricts the frequency of possible uses
@export var use_timeout: float = 0.0

## Once - pressing and holding the interaction key is effective only once - holding has no effect
##
## Continuous - press and hold to interact repeatedly
@export_enum("Once", "Continuous") var usage_mode: String = "Once"

var _use_timeout_left: float = 0.0

var _original_tree: Node3D
const POSITION_STORE_OFFSET_Y = 5000
func _ready() -> void:
	super()
	if interaction_type != "Instant":
		push_error("Items should always have the 'Instant' interaction type")
	interacted.connect(_internal_on_interacted)

func _internal_on_interacted(_body: Variant) -> void:
	# Use the interaction signal to attempt pick up the item
	
	SignalBus.attempted_item_pick_up.emit(self)
	
func prepare_for_pickup() -> void:
	parent.freeze = true
	parent.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	
	_original_tree = parent.get_parent()
	parent.get_parent().remove_child(parent)
	parent.transform = Transform3D.IDENTITY
	
	# Zero out collision layer and mask to disable collisions and interactions
	parent.collision_layer = Bits.ZERO
	parent.collision_mask = Bits.ZERO
	collision_layer = Bits.ZERO
	collision_mask = Bits.ZERO

## Invoked when a player uses the item while holding it
func use(by_who: Variant):
	if not is_usage_enabled:
		return
	
	if usage_mode == "Once":
		if not Input.is_action_just_pressed("use_item"):
			return
	
	if _use_timeout_left > 0.0:
		return
		
	used.emit(by_who)
	_use_timeout_left = use_timeout

## Invoked when a player drops the item while holding it
func drop(_by_who: Variant):
	parent.freeze = false
	parent.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	# Zero out collision layer and mask to disable collisions and interactions
	parent.collision_layer = Bits.from([Layer.World])
	parent.collision_mask = Bits.from([Layer.World])
	collision_layer = Bits.from([Layer.Interactables])
	collision_mask = Bits.from([Layer.World, Layer.Interactables])
	
	# Save global transform
	var global_xform = parent.global_transform

	# Reparent
	parent.get_parent().remove_child(parent)
	_original_tree.add_child(parent)

	# Restore global transform
	parent.global_transform = global_xform

func prepare_for_store() -> void:
	parent.position.y += POSITION_STORE_OFFSET_Y

func prepare_for_retrieve() -> void:
	parent.position.y -= POSITION_STORE_OFFSET_Y	

## Handles counting down the potential interaction timeout
func _process(delta: float) -> void:
	if _use_timeout_left > 0:
		_use_timeout_left -= delta
