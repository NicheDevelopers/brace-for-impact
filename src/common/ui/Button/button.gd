extends Button

@onready var audio_player = $AudioStreamPlayer

func _on_button_down() -> void:
	audio_player.play(0.0)
