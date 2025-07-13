extends Node

class_name LEDComponent

@onready var _parent_mesh: MeshInstance3D = get_parent() as MeshInstance3D
@onready var _material := StandardMaterial3D.new()

## Whether the LED is currently ON or OFF.
@export var _is_on := false

## LED color.
@export_enum("Green", "Red") var _color := "Green"

## Emission intensity when the LED is ON.
@export var emission_strength := 2.0

## Darkening factor for the LED's color when it is OFF.
@export var darken_when_off_strength := 0.3

## Color for the LED when set to Red.
@export var color_red = Color(0.9, 0.15, 0.15)

## Color for the LED when set to Green.
@export var color_green = Color(0.15, 0.8, 0.15)

## Default color when the LED is OFF and no specific OFF color is selected.
@export var color_off = Color(0.7, 0.7, 0.7)

## If true, the LED will appear darkened green when OFF, indicating that it can only be green.
@export var green_when_off := false

## If true, the LED will appear darkened red when OFF, indicating that it can only be red.
@export var red_when_off := false

func _ready() -> void:
	if not _parent_mesh:
		push_error("Error: Parent is not a MeshInstance3D.")
		return

	if green_when_off and red_when_off:
		push_error("Both 'green_when_off' and 'red_when_off' cannot be true simultaneously.")
		return

	_parent_mesh.material_override = _material

	if green_when_off:
		_material.albedo_color = color_green.darkened(darken_when_off_strength)
	elif red_when_off:
		_material.albedo_color = color_red.darkened(darken_when_off_strength)
	else:
		_material.albedo_color = color_off

	_material.emission_enabled = false  # Start with emission disabled
	update_emission()

func toggle():
	_is_on = not _is_on
	update_emission()

func turn_off():
	_is_on = false
	update_emission()

func turn_on():
	_is_on = true
	update_emission()

func set_red():
	_color = "Red"
	update_emission()

func set_green():
	_color = "Green"
	update_emission()

func is_on() -> bool:
	return _is_on

func update_emission():    
	if _is_on:
		_material.emission_enabled = true
		if _color == "Green":
			_material.albedo_color = color_green
			_material.emission = color_green * emission_strength
		elif _color == "Red":
			_material.albedo_color = color_red
			_material.emission = color_red * emission_strength
	else:
		_material.emission_enabled = false
		if green_when_off:
			_material.albedo_color = color_green.darkened(darken_when_off_strength)
		elif red_when_off:
			_material.albedo_color = color_red.darkened(darken_when_off_strength)
		else:
			_material.albedo_color = color_off
