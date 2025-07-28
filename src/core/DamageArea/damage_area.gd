extends Area3D

@export var damage_curve: Curve

var inside: Dictionary = {}

func _process(delta: float) -> void:
	var bodies = get_overlapping_bodies()

	for body in bodies:
		if body.has_method("is_in_group"):
			if body.is_in_group(Group.HasHealthComponent):
				if not inside.has(body):
					inside[body] = 0.0
				inside[body] += delta

	var to_remove = []
	for body in inside.keys():
		if not bodies.has(body):
			to_remove.append(body)
	for body in to_remove:
		inside.erase(body)

	apply_damage(delta)

func apply_damage(delta: float) -> void:
	for body in inside.keys():
		var time_in_area = inside[body]
		var damage_to_apply = damage_curve.sample_baked(time_in_area)
		var health = body.get_node_or_null("HealthComponent")
		if health:
			health.damage(damage_to_apply, get_parent().name)
