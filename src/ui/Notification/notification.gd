extends Control

@onready var label = $Label

func _ready() -> void:
	hide()

func show_message(message) -> void:
	label.text = message
	show()

func _on_exit_pressed() -> void:
	hide()
