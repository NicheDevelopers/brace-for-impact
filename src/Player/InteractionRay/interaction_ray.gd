extends RayCast3D

# Stores the last encountered collider to toggle its Label3D
var last_collider: InteractionComponent

func _physics_process(_delta: float) -> void:
	if last_collider:
		last_collider.hide_label()
	
	if not is_colliding():
		last_collider = null
		return
	
	var collider := get_collider()
	
	if collider is not InteractionComponent:
		return
	
	last_collider = collider
	if not collider.can_interact_with(self.owner):
		return
	
	collider.show_label()
	
	var is_pressed := false
	var type: String = collider.interaction_type
	
	if type == "Instant":
		var mode: String = collider.instant_interaction_mode
		
		if mode == "Once":
			is_pressed = Input.is_action_just_pressed(collider.interact_action_name)
		elif mode == "Continuous":
			is_pressed = Input.is_action_pressed(collider.interact_action_name)
		else:
			printerr("Invalid interaction mode: " + mode)
	elif type == "Lasting":
		is_pressed = Input.is_action_just_pressed(collider.interact_action_name)
	else: printerr("Invalid interaction type: " + type)
	
	if is_pressed:
		collider.interact(self.owner)
