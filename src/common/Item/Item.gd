extends Interactable

class_name Item

func _on_interacted(body: Variant) -> void:
	print(body.name + " picked up " + self.name)
	self.get_parent().remove_child(self)
	# TODO: Use an enum with usage like Layers.PLAYER instead of hardcoded layer numbers
	self.collision_layer = Bits.ZERO
	self.collision_mask = Bits.ZERO
	self.transform = Transform3D.IDENTITY
	SignalDispatcher.item_picked_up.emit(self)
