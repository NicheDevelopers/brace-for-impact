extends RayCast3D

# Stores the last encountered collider to toggle its Label3D
var last_collider: Interactable

func _physics_process(_delta: float) -> void:	
	if last_collider:
		last_collider.hide_label()
		
	if not is_colliding():
		return
		
	var collider := get_collider()
		
	if collider is not Interactable:
		return
	
	last_collider = collider
	if not collider.is_interaction_enabled:
		return
	
	collider.show_label()
	
	var is_pressed := false
	var mode: String = collider.interaction_mode
	
	if mode == "Once":
		is_pressed = Input.is_action_just_pressed(collider.interact_action_name)
	elif mode == "Continuous":
		is_pressed = Input.is_action_pressed(collider.interact_action_name)
	else:
		printerr("Invalid interaction mode " + mode)
		
	if is_pressed:
		collider.interact(self.owner)
