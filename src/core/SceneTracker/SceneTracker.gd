extends Node

class _Scenes:
	var MAIN_MENU = "res://src/ui/MainMenu/MainMenu.tscn"
	var ROOT = "res://src/Root.tscn"
	var SETTINGS = "res://src/ui/Settings/SettingsMenu/SettingsMenu.tscn"
	var VIDEO_SETTINGS = "res://src/ui/Settings/VideoSettings/VideoSettings.tscn"
	var AUDIO_SETTINGS = "res://src/ui/Settings/AudioSettings/AudioSettings.tscn"
	var INPUT_SETTINGS = "res://src/ui/Settings/InputSettings/InputSettings.tscn"

var current_scene = null
@onready var previous_scenes = []
var just_went_back = false
@onready var scenes = _Scenes.new()

func _ready() -> void:
	pass

func set_current_scene(scene):
	if current_scene != null and not just_went_back:
		previous_scenes.append(current_scene)
	just_went_back = false
	current_scene = scene
	print_debug("current_scene is now ", scene, " and previous scenes are: ", previous_scenes)

func go_to_previous_scene() -> void:
	call_deferred("_deferred_previous_scene")

func _deferred_previous_scene() -> void:
	var previous_scene = previous_scenes.pop_back()
	print_debug(previous_scene)
	just_went_back = true
	get_tree().change_scene_to_file(previous_scene)
