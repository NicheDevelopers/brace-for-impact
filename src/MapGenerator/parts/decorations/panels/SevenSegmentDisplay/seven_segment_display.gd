extends Node3D

@onready var digits: Array[DigitNode] = [
	$"digit-1",
	$"digit-2",
	$"digit-3",
	$"digit-4",
]

@onready var plus_vertical_part: Node3D = $"plus/plus-vertical"
@onready var dot: Node3D = $dot

@onready var timer: Timer = Timer.new()

@export var value_change_interval: float = 0.5
@export var min_random_value: float = -9999.0
@export var max_random_value: float = 9999.0

func _round_and_abs(x: float):
	if x > 0:
		return abs(floor(x))
	return abs(ceil(x))

func set_number(number: float):
	if (number < 0):
		plus_vertical_part.hide()
	else: plus_vertical_part.show()
	
	var value: int
	if  _round_and_abs(number) >= 1000:
		value =  _round_and_abs(number)
		dot.hide()
	else:
		value =  _round_and_abs(number * 10)
		dot.show()
	
	var digit_count := digits.size()
	
	for i in range(digit_count):
		var digit_index := digit_count - 1 - i
		var digit_value := (value / int(pow(10, digit_index))) % 10
		digits[i].set_digit(digit_value)

func _ready():
	timer.wait_time = value_change_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_random_timer_timeout)
	add_child(timer)

func _on_random_timer_timeout():
	var random_number = Random.float(min_random_value, max_random_value)
	set_number(random_number)
