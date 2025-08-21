extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var detection_area = $DetectionArea
@onready var door_indicators = [$DoorSingle/Door/DoorIndicator, $DoorSingle/Door/DoorIndicator2]

@export var is_locked := false
@export var is_locked_manually := false
var _is_moving := false

func _ready() -> void:
	_update_door_indicators()

func lock():
	is_locked = true
	_update_door_indicators()
	
func unlock():
	is_locked = false
	_update_door_indicators()
	
func _physics_process(_delta: float) -> void:
	_is_moving = animation_player.is_playing()
	_update_door_indicators()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
		
	if is_locked: 
		return
	
	animation_player.speed_scale = 1.5
	
	if not animation_player.is_playing():
		animation_player.play("open")

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
		
	if is_locked:
		return
		
	animation_player.speed_scale = -1.5

	if not animation_player.is_playing():
		animation_player.play("open", -1.0, 1.5, true)

func _update_door_indicators():
	for indicator in door_indicators:
		indicator.update(is_locked, is_locked_manually, _is_moving)
