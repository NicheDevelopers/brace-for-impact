extends CanvasLayer

@onready var popup = $Panel

func _show(message) -> void:
	popup.find_child("Label").text = message
	popup.modulate = Color(1, 1, 1, 1)
	popup.show()

func _on_exit_pressed() -> void:
	popup.hide()
