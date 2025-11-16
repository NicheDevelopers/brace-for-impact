extends Control

@onready var fullscreen_toggle = $ColorRect/VBoxContainer/fullscreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_toggle.set_pressed_no_signal(is_fullscreen)
	
	SceneTracker.set_current_scene(SceneTracker.scenes.VIDEO_SETTINGS)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	SceneTracker.go_to_previous_scene()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
