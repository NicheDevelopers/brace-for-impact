extends SpotLight3D

func _physics_process(delta: float) -> void:
	rotate(Vector3.UP, 10 * delta)
