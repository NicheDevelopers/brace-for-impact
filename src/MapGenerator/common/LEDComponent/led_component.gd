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

## Animation duration in seconds
@export var animation_duration := 0.4

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

## Blinking mode enabled
@export var blink_enabled := false

## Time in seconds for one complete blink cycle (on + off)
@export var blink_cycle_time := 1.0

## Blink animation duration (fade in/out time)
@export var blink_fade_time := 0.4

# Separate tween for blinking to not interfere with main animations
var _blink_tween: Tween
var _is_blinking := false

# Tween for smooth animations
var _tween: Tween

var _current_emission_intensity := 0.0

func _ready() -> void:
	if not _parent_mesh:
		push_error("Error: Parent is not a MeshInstance3D.")
		return

	if green_when_off and red_when_off:
		push_error("Both 'green_when_off' and 'red_when_off' cannot be true simultaneously.")
		return

	_parent_mesh.material_override = _material

	# Initialize material
	_material.emission_enabled = true
	_material.emission_energy = 1.0
	
	# Set initial albedo color
	if green_when_off:
		_material.albedo_color = color_green.darkened(darken_when_off_strength)
	elif red_when_off:
		_material.albedo_color = color_red.darkened(darken_when_off_strength)
	else:
		_material.albedo_color = color_off
	
	if _is_on:
		_current_emission_intensity = 1.0
		update_emission_immediate()
	else:
		_current_emission_intensity = 0.0
		var led_color = color_green if _color == "Green" else color_red
		_material.emission = led_color * 0.0  # Start with no emission

func toggle():
	_is_on = not _is_on
	animate_emission()

func turn_on():
	if _is_on:
		return
	_is_on = true
	animate_emission()
	# Wait for animation to complete before starting blink
	if blink_enabled:
		await get_tree().create_timer(animation_duration).timeout
		_update_blink_state()

func turn_off():
	if not _is_on:
		return
	_is_on = false
	_is_blinking = false
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	animate_emission()

func set_red():
	_color = "Red"
	if _is_on:
		var led_color = color_red
		_material.emission = led_color * emission_strength * _current_emission_intensity
		_material.albedo_color = led_color
	else:
		update_off_state()

func set_green():
	_color = "Green"
	if _is_on:
		var led_color = color_green
		_material.emission = led_color * emission_strength * _current_emission_intensity
		_material.albedo_color = led_color
	else:
		update_off_state()

func is_on() -> bool:
	return _is_on

func animate_emission():
	# Cancel any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	
	var target_intensity = 1.0 if _is_on else 0.0
	
	# Animate the emission intensity
	_tween.tween_method(
		_update_emission_intensity,
		_current_emission_intensity,
		target_intensity,
		animation_duration
	)
	
	# Also animate albedo color change
	var target_albedo = get_target_albedo_color()
	_tween.parallel().tween_property(
		_material,
		"albedo_color",
		target_albedo,
		animation_duration
	)

func _update_emission_intensity(intensity: float):
	_current_emission_intensity = intensity
	
	var led_color = color_green if _color == "Green" else color_red
	
	_material.emission = led_color * emission_strength * intensity
	_material.emission_energy = 1.0

func get_target_albedo_color() -> Color:
	if _is_on:
		return color_green if _color == "Green" else color_red
	else:
		if green_when_off:
			return color_green.darkened(darken_when_off_strength)
		elif red_when_off:
			return color_red.darkened(darken_when_off_strength)
		else:
			return color_off

## Update albedo color when LED is off and color changes
func update_off_state():
	if not _is_on:
		_material.albedo_color = get_target_albedo_color()

## Updates without animation
func update_emission_immediate():
	_current_emission_intensity = 1.0 if _is_on else 0.0
	var led_color = color_green if _color == "Green" else color_red
	_material.emission = led_color * emission_strength * _current_emission_intensity
	_material.emission_energy = 1.0
	_material.albedo_color = get_target_albedo_color()

func set_blink(enabled: bool):
	blink_enabled = enabled
	_update_blink_state()

func _update_blink_state():
	if blink_enabled and _is_on:
		if not _is_blinking:
			_is_blinking = true
			_start_blink_cycle()
	else:
		_is_blinking = false
		if _blink_tween and _blink_tween.is_valid():
			_blink_tween.kill()
		# Restore normal on state if LED is on
		if _is_on:
			animate_emission()

func _start_blink_cycle():
	if not _is_blinking:
		return
		
	# Kill any existing blink animation
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	# Create new blink animation
	_blink_tween = create_tween()
	_blink_tween.set_loops()  # Loop forever
	
	# Calculate timings
	var half_cycle = blink_cycle_time / 2.0
	var on_time = max(0.0, half_cycle - blink_fade_time)
	var off_time = max(0.0, half_cycle - blink_fade_time)
	
	# Blink cycle: fade in -> stay on -> fade out -> stay off
	_blink_tween.tween_method(_update_emission_intensity, 0.0, 1.0, blink_fade_time)
	_blink_tween.tween_interval(on_time)
	_blink_tween.tween_method(_update_emission_intensity, 1.0, 0.0, blink_fade_time)
	_blink_tween.tween_interval(off_time)
