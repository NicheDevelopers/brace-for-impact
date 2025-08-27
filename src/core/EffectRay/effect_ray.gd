extends RayCast3D

class_name EffectRay

enum Effect {
	DAMAGE, # Damages everything
	RAPAIR # Repairs walls, damages players
}

@export var effect_type = Effect.DAMAGE
@export var damage_strength: float = 10.0
@export var heal_strength: float = 10.0

func damageEffect(collider: Object, by_who):
	var health = collider.get_node("HealthComponent")
	health.damage(damage_strength, by_who)

func repairEffect(collider: Object, by_who):
	var health = collider.get_node("HealthComponent")
	print("collider.get_node(HealthComponent): ", health)
	print("health.type: ", health.type)
	if health.type == HealthComponent.HealthComponentType.PLAYER:
		health.damage(damage_strength, by_who)
	elif health.type == HealthComponent.HealthComponentType.STRUCTURE:
		health.heal(heal_strength, by_who)

func applyEffect(collider: Object, by_who):
	match effect_type:
		Effect.DAMAGE:
			damageEffect(collider, by_who)
		Effect.RAPAIR:
			repairEffect(collider, by_who)
		_:
			push_error("This type of effect is not handled")

## Searches for a node which has a HealthComponent and applies damage if found
func trigger(by_who: Variant):
	if not is_colliding():
		return
	
	var collider = get_collider()
	print("collider: ", collider)
	while collider != null:
		if collider.has_method("is_in_group"):
			print("collider.has_method")
			if collider.is_in_group(Group.HasHealthComponent):
				print("collider.is_in_group")
				applyEffect(collider, by_who)
				return
		
		collider = collider.get_parent()
		if collider.get_parent() == null:
			# Nothing with a health component was hit
			return
