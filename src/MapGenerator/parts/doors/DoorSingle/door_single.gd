extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var detection_area = $DetectionArea

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
	
	animation_player.speed_scale = 1.5
	
	if not animation_player.is_playing():
		animation_player.play("open")

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
		
	animation_player.speed_scale = -1.5

	if not animation_player.is_playing():
		animation_player.play("open", -1.0, 1.5, true)
