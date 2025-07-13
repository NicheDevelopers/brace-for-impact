extends Node3D

@onready var diode = $Base/Diode
@onready var position_on = $Base/PositionOn
@onready var position_off = $Base/PositionOff
@export var led_green_material: Material
@export var led_red_material: Material
@export var led_off_material: Material

const on_percent = 40
const off_percent = 80

func switch_off():
	position_on.hide()
	diode.material_override = led_red_material
	
func switch_on():
	position_off.hide()
	diode.material_override = led_green_material

func switch_disabled():
	var level_pos = randi() % 2
	if level_pos == 0:
		position_on.hide()
	else:
		position_off.hide()
	diode.material_override = led_off_material
	
func _ready() -> void:
	var state = randi() % 100
	if state < on_percent:
		switch_off()
	elif state < off_percent:
		switch_on()
	else:
		switch_disabled()
