extends StaticBody3D


func _on_health_component_killed(by_who: Variant) -> void:
	queue_free()
