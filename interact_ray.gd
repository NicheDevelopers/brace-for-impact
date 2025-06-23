extends RayCast3D

@onready var prompt: Label = $Prompt

func _physics_process(delta: float) -> void:
	var prompt_text := ""
	
	if is_colliding():
		var collider := get_collider()
		prompt.text = collider.name
