extends Node3D

@export var scene: PackedScene
@export var randomize_rotation := false
@export var initial_velocity_multiplier := 1.0

@onready var root_node: Node = get_tree().root.get_child(0)
@onready var target_ray: RayCast3D = $TargetRay
@onready var spawn_direction := target_ray.target_position

func spawn():
	if not scene:
		push_error("SpawnerComponent: No scene set")
		return

	var instance: Node = scene.instantiate()
	
	if instance is not Node3D:
		push_warning("SpawnerComponent: Attempt to spawn a non-3D scene")
		return
	
	root_node.add_child(instance)
	
	instance.global_position = global_position
	
	if randomize_rotation:
		_randomize_rotation(instance)
	else:
		instance.global_rotation = self.global_rotation
	
	_apply_initial_velocity(instance)
	
	return instance

func _randomize_rotation(node: Node3D):
	node.rotation = Vector3(
		Random.float() * TAU,
		Random.float() * TAU,
		Random.float() * TAU
	)

func _apply_initial_velocity(node: Node3D):
	var front_vector = global_transform.basis.z.normalized()
	var velocity = front_vector * initial_velocity_multiplier
	if node.has_method("apply_impulse"):
		node.apply_impulse(velocity)
	elif node.has_method("apply_central_impulse"):
		node.apply_central_impulse(velocity)
	elif "linear_velocity" in node:
		node.linear_velocity = velocity
