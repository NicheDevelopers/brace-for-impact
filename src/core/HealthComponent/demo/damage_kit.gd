extends StaticBody3D

func _on_interacted(body: Variant) -> void:
	var health: HealthComponent = body.get_node("HealthComponent")
	health.damage(15.0, self)
