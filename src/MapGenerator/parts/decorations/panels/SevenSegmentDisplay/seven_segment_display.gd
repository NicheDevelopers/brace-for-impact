extends Node3D

@onready var digits: Array[DigitNode] = [
	$"digit-1",
	$"digit-2",
	$"digit-3",
	$"digit-4",
]

@onready var plus_vertical_part: Node3D = $"plus/plus-vertical"
@onready var dot: Node3D = $dot

@onready var timer: Timer = $Timer

## Whether this 7-segment display is powered on
@export var enabled: bool = true

## The smallest number that the device will ever display
@export var min_value: float = -9999.0

## The biggest number that the device will ever display
@export var max_value: float = 9999.0

## Fixed[br]
## - the 7-segement displays the same number until changed manually
## with the [method set_number] function
## [br][br]
## SoftRandom[br]
## - the displayed number changes by a random value between
## [member softrandom_min_change] and [member softrandom_max_change]
## (inclusive) every [member softrandom_interval] seconds, clamped
## between [member min_value] and [member max_value]
## [br][br]
## FullRandom[br]
## - the 7-segment display chooses a number to display at random
## every [member value_change_interval]. Clamped
## between [member min_value] and [member max_value]
@export_enum("Fixed", "SoftRandom", "FullRandom") var display_mode = "SoftRandom"

@export_group("Fixed Display Mode", "fixed")
@export var fixed_displayed_number: float = 100.0

@export_group("SoftRandom Display Mode", "softrandom")
@export var softrandom_interval: float = 0.5
@export var softrandom_starting_value: float = 500.0
@export var softrandom_min_change: float = -10.0
@export var softrandom_max_change: float = 10.0

@export_group("FullRandom Display Mode", "fullrandom")
@export var fullrandom_interval: float = 0.5

var _current_value: float

func _round_and_abs(x: float):
	if x > 0:
		return abs(floor(x))
	return abs(ceil(x))

## Returns the currently displayed number.
func get_number():
	return _current_value

## Sets the displayed number.[br]
## Meant to be used externally when [member display_mode] is set to "Fixed"
func set_number(number: float):
	_current_value = clampf(number, min_value, max_value)
	if (_current_value < 0):
		plus_vertical_part.hide()
	else: plus_vertical_part.show()
	
	var value: int
	if  _round_and_abs(_current_value) >= 1000:
		value =  _round_and_abs(_current_value)
		dot.hide()
	else:
		value =  _round_and_abs(_current_value * 10)
		dot.show()
	
	var digit_count := digits.size()
	
	for i in range(digit_count):
		var digit_index := digit_count - 1 - i
		var digit_value := int(value / pow(10, digit_index)) % 10
		digits[i].set_digit(digit_value)

## Sets the display mode of the device.[br]
## Accepted modes: "Fixed", "SoftRandom", "FullRandom"
func set_mode(mode: String):
	display_mode = mode
	if mode == "Fixed":
		set_number(fixed_displayed_number)
		timer.stop()
	if mode == "SoftRandom":
		set_number(softrandom_starting_value)
		timer.wait_time = softrandom_interval
		timer.start()
		if timer.timeout.is_connected(_fullrandom_trigger):
			timer.timeout.disconnect(_fullrandom_trigger)
		if not timer.timeout.is_connected(_softrandom_trigger):
			timer.timeout.connect(_softrandom_trigger)
	if mode == "FullRandom":
		timer.wait_time = fullrandom_interval
		timer.start()
		if timer.timeout.is_connected(_softrandom_trigger):
			timer.timeout.disconnect(_softrandom_trigger)
		if not timer.timeout.is_connected(_fullrandom_trigger):
			timer.timeout.connect(_fullrandom_trigger)

func _ready():
	set_mode(display_mode)

## Update the displayed number in SoftRandom mode
func _softrandom_trigger():
	var change = Random.float(softrandom_min_change, softrandom_max_change)
	set_number(get_number() + change)

## Update the displayed number in FullRandom mode
func _fullrandom_trigger():
	var random_number = Random.float(min_value, max_value)
	set_number(random_number)
