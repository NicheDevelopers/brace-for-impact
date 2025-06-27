extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTracker.set_current_scene(SceneTracker.scenes.SETTINGS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_video_pressed() -> void:
	get_tree().change_scene_to_file(SceneTracker.scenes.VIDEO_SETTINGS)

func _on_audio_pressed() -> void:
	get_tree().change_scene_to_file(SceneTracker.scenes.AUDIO_SETTINGS)

func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file(SceneTracker.scenes.INPUT_SETTINGS)

func _on_back_pressed() -> void:
	SceneTracker.go_to_previous_scene()
	
