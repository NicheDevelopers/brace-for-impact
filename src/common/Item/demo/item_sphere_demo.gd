extends Item

func _on_used(body: Variant) -> void:
	print(body.name + " used item: " + self.name)
