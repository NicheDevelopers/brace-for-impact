extends Button

@onready var audio_player = $AudioStreamPlayer

func _on_button_down_play_audio() -> void:
	audio_player.play()
