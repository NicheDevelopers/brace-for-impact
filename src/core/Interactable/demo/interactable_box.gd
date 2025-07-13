extends Interactable

func _on_interacted(body: Variant) -> void:
	self.rotate(Vector3.UP, 5)
