extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTracker.set_current_scene(SceneTracker.scenes.VIDEO_SETTINGS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	SceneTracker.go_to_previous_scene()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
