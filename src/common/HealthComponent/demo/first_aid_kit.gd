extends Interactable

func _on_interacted(body: Variant) -> void:
	var health: HealthComponent = body.get_node("HealthComponent")
	health.heal(15.0, self)
