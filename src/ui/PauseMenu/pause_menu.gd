extends Control

@onready var pause_menu_container = $ColorRect
@onready var resume_button = $ColorRect/HBoxContainer/MarginContainer/VBoxContainer/ResumeButton

func _ready() -> void:
	_hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle()

func _toggle() -> void:
	if pause_menu_container.visible:
		_hide()
	else:
		_show()

func _show() -> void:
	resume_button.grab_focus()
	pause_menu_container.show()
	pause_menu_container.mouse_filter = Control.MOUSE_FILTER_STOP
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _hide() -> void:
	pause_menu_container.hide()
	pause_menu_container.mouse_filter = Control.MOUSE_FILTER_PASS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if pause_menu_container.visible:
		get_viewport().set_input_as_handled()

func _on_resume_button_button_down() -> void:
	_hide()
