extends Node3D

func _on_button_interacted(_body: Variant) -> void:
	$Boombox/RandomAudioPlayer.stop()
	$Boombox2/RandomAudioPlayer.stop()
	$Rotator/Boombox/RandomAudioPlayer.stop()
	$AlarmBox/RandomAudioPlayer.stop()

func _process(delta: float) -> void:
	$Rotator.rotate_y(2 * delta)
