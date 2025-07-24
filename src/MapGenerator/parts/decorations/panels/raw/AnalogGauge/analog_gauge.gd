extends Node3D
@onready var dial: MeshInstance3D = $Base/Plate/Dial

func _ready() -> void:
	var rand = Random.int(-110,110)
	dial.rotate(Vector3.UP, deg_to_rad(rand))
