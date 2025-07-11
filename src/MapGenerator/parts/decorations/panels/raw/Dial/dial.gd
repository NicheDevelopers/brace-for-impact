extends Node3D
@onready var dial = $Dial

func _ready() -> void:
	var rand = randi_range(0,360)
	dial.rotate(Vector3.UP, deg_to_rad(rand))
