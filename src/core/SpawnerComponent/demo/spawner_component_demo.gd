extends Node3D

@onready var spawner := $CSGTorus3D/SpawnerComponent
@onready var spawner2 := $CSGTorus3D2/SpawnerComponent
@onready var spawner3 := $CSGTorus3D3/SpawnerComponent
@onready var spawner4 := $CSGTorus3D4/SpawnerComponent

@export var timeout := 1.0

var _timeout_left := 0.0

func _process(delta: float) -> void:
	_timeout_left -= delta
	
	if _timeout_left > 0.0:
		return
		
	spawner.spawn()
	spawner2.spawn()
	spawner3.spawn()
	if spawner4: spawner4.spawn()
	
	_timeout_left = timeout
