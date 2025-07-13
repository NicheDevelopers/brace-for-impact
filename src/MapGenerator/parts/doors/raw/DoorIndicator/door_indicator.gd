extends Node3D

@onready var is_locked_led: LEDComponent = $Base/Diode1/LEDComponent
@onready var is_locked_manually_led: LEDComponent = $Base/Diode2/LEDComponent
@onready var is_moving_led: LEDComponent = $Base/Diode3/LEDComponent

func _ready() -> void:
	is_locked_manually_led.red_when_off = true
	is_moving_led.green_when_off = true
	
	is_locked_led.set_green()
	is_locked_led.turn_on()
	
	is_locked_manually_led.turn_off()
	
	is_moving_led.turn_off()
	
func update(is_locked: bool, is_locked_manually: bool, is_moving: bool):
	if is_locked:
		_indicate_locked()
	else:
		_indicate_unlocked()
	
	if is_locked_manually:
		_indicate_locked_manually()
	else:
		_indicate_unlocked_manually()
		
	if is_moving:
		_indicate_moving()
	else:
		_indicate_stationary()

## Indicate that the door is locked, independent of how it was locked
func _indicate_locked():
	is_locked_led.set_red()
	is_locked_led.turn_on()
	
## Indicate that the door is unlocked
func _indicate_unlocked():
	is_locked_led.set_green()
	is_locked_led.turn_on()
	
## Indicate that the door was locked manually, by some Player
func _indicate_locked_manually():
	is_locked_manually_led.turn_on()
	
func _indicate_unlocked_manually():
	is_locked_manually_led.turn_off()
	
## Indicate that the door is moving
func _indicate_moving():
	is_moving_led.turn_on()
	
## Indicate that the door is stationary
func _indicate_stationary():
	is_moving_led.turn_off()
