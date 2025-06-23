extends CollisionObject3D

class_name Interactable

signal interacted(body)

@export var prompt_message: String = "Interact"
@export var is_enabled: bool = true
@export var interact_action_name: String = "interact"
@export_enum("Once", "Continuous") var interaction_mode: String = "Once"

func interact(body):
	interacted.emit(body)
	
func get_prompt() -> String:
	var key_name := ""
	for action in InputMap.action_get_events(self.interact_action_name):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
	return prompt_message + "\n[" + key_name + "]"
