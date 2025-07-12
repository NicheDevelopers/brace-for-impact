extends Node3D

class_name DigitNode

var digit_bitmasks: Array[int] = [
	0b1111110, # digit zero
	0b0110000, # digit one
	0b1101101, # digit two
	0b1111001, # digit three
	0b0110011, # digit four
	0b1011011, # digit five
	0b1011111, # digit six
	0b1110000, # digit seven
	0b1111111, # digit eight
	0b1111011, # digit nine
]

@onready var segments: Array[MeshInstance3D] = [
	$"seven-segment-digit/a",
	$"seven-segment-digit/b",
	$"seven-segment-digit/c",
	$"seven-segment-digit/d",
	$"seven-segment-digit/e",
	$"seven-segment-digit/f",
	$"seven-segment-digit/g"
	]

func set_digit(digit: int):
	var bitmask = digit_bitmasks[digit]
	for i in range(segments.size()):
		if bitmask & (1 << (6-i)):
			segments[i].show()
		else:
			segments[i].hide()

func _ready():
	set_digit(5)
