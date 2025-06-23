extends Interactable

func _on_interacted(body: Variant) -> void:
	print(body.name + " interacted with " + self.name)
	self.rotate(Vector3.UP, 5)
