extends Node3D

func _on_interacted(_body: Variant) -> void:
	$RandomAudioPlayer.play()
