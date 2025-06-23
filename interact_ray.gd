extends RayCast3D

@onready var prompt: Label = $Prompt

func _physics_process(delta: float) -> void:
	prompt.text = ""
	
	if is_colliding():
		var collider := get_collider()
		
		if collider is Interactable:
			if collider.is_enabled:
				prompt.text = collider.get_prompt()
				
				if Input.is_action_just_pressed(collider.interact_action_name):
					collider.interact(self.owner) # Passes the parent Player node
