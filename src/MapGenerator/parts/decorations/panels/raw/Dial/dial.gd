extends Node3D
@onready var dial = $Base/Dial

func _ready() -> void:
	var rand = Random.int(0,360)
	dial.rotate(Vector3.UP, deg_to_rad(rand))
