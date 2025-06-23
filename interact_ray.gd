extends RayCast3D

@onready var prompt: Label = $Prompt

func _physics_process(delta: float) -> void:
	prompt.text = ""
	
	if is_colliding():
		var collider := get_collider()
		
		if collider is Interactable:
			if collider.is_enabled:
				prompt.text = collider.get_prompt()
				
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
