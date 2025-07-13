extends RayCast3D

class_name DamageRay

@export var damage_dealt: float = 10.0

## Searches for a node which has a HealthComponent and applies damage if found
func trigger(by_who: Variant):
	if not is_colliding():
		return
	
	var collider = get_collider()
	
	while collider != null:
		if collider.has_method("is_in_group"):
			if collider.is_in_group(Group.HasHealthComponent):
				var health = collider.get_node("HealthComponent")
				health.damage(damage_dealt, by_who)
				return
		collider = collider.get_parent()
		if collider.get_parent() == null:
			# Nothing with a health component was hit
			return
