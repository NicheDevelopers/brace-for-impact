extends Node3D

@export var is_turned_on := false

## Rate at which the flashlight follows its parent.
@export var follow_speed := 15.0  
@export var energy := 16.0
@export var indirect_energy := 5.0
@export var volumetric_fog_energy := 2.0

@onready var parent = get_parent()
@onready var spotlight = $SpotLight # Assumes your SpotLight3D is named "SpotLight"    

var current_rotation_basis: Basis

func _ready():
	current_rotation_basis = spotlight.global_transform.basis
	_update_light(spotlight)

func _physics_process(delta: float):
	
	if Input.is_action_just_pressed("toggle_flashlight"):
		is_turned_on = not is_turned_on
		_update_light(spotlight)
	
	var target_position = parent.global_transform.origin
	var target_rotation_basis = parent.global_transform.basis

	current_rotation_basis = current_rotation_basis.slerp(target_rotation_basis, follow_speed * delta)

	spotlight.global_transform = Transform3D(current_rotation_basis, target_position)

func _update_light(light: Light3D):
	if is_turned_on:
		light.light_energy = energy
		light.light_indirect_energy = indirect_energy
		light.light_volumetric_fog_energy = volumetric_fog_energy
	else:
		light.light_energy = 0.0
		light.light_indirect_energy = 0.0
		light.light_volumetric_fog_energy = 0.0
	
