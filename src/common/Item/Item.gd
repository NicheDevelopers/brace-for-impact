extends Interactable

class_name Item

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

func _on_interacted(body: Variant) -> void:
	print(body.name + " picked up " + self.name)
	
	self.freeze = true
	self.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	
	self.get_parent().remove_child(self)
	self.collision_layer = Bits.ZERO
	self.collision_mask = Bits.ZERO
	self.transform = Transform3D.IDENTITY
	SignalBus.item_picked_up.emit(self)

func use(body):
	var mode: String = self.usage_mode
	
	if not self.is_usage_enabled:
		return
	
	if mode == "Once":
		if not Input.is_action_just_pressed("use_item"):
			return
	
	if _use_timeout_left > 0.0:
		return
		
	used.emit(body)
	_use_timeout_left = use_timeout
	
## Handles counting down the potential interaction timeout
func _process(delta: float) -> void:
	if _use_timeout_left > 0:
		_use_timeout_left -= delta
