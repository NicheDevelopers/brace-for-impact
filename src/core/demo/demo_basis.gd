extends Node3D

@export var third_person_camera: bool = false

@onready var player: Player = $Player

func _ready() -> void:
	if third_person_camera:
		player.toggle_third_person_camera()
