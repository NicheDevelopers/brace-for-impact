extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	SceneTracker.set_current_scene(SceneTracker.scenes.MAIN_MENU)

func _process(_delta: float) -> void:
	pass

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file(SceneTracker.scenes.ROOT)

func _on_continue_pressed() -> void:
	print("saving not implemented yet")
	
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(SceneTracker.scenes.SETTINGS)

func _on_quit_pressed() -> void:
	get_tree().quit()
