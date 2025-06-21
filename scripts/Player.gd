extends CharacterBody3D

# TODO: replace this with a config value that's taken from the game settings
@export_group("mouse")
@export var mouse_sensitivity := 0.001
@export var mouse_twist := 0.0
@export var mouse_pitch := 0.0

@export_group("player_properties")
@export var speed = 4.0
@export var acceleration = 8.0
@export var sprint_speed_multiplier = 2.0
@export var crouch_speed_multiplier = 0.5
# placeholder values correct for the default pill-shaped model
# TODO: change these values to be correct for the target player model
@export var standing_height = 0.7
@export var crouching_height = standing_height - 0.7
# placeholder variable which determines whether the player should obey the laws of gravity or not.
# if there is no gravity, the player can jump, but not move up/down freely.
# the reverse happens if there is no gravity.
@export var no_gravity_mode := 0

@onready var twist_pivot: Node3D = $TwistPivot
@onready var pitch_pivot: Node3D = $TwistPivot/PitchPivot
@onready var camera: Camera3D = $TwistPivot/PitchPivot/Camera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if no_gravity_mode:
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	else:
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if no_gravity_mode:
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	else:
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := camera.global_basis.z
	var right := camera.global_basis.x
	var direction := forward * input.y + right * input.x
	var crouch_value := 1.0
	var sprint_value := 1.0
	direction.y = 0.0
	direction = direction.normalized()
	if Input.get_action_strength("crouch"):
		crouch_value = crouch_speed_multiplier
		camera.position.y = crouching_height
	elif Input.get_action_strength("sprint") and input[1] < 0.0:
		sprint_value = sprint_speed_multiplier
		camera.position.y = standing_height
	else:
		camera.position.y = standing_height
	velocity = velocity.move_toward(direction * speed * crouch_value * sprint_value, acceleration * delta)
	#if no_gravity_mode:
		#input.y = Input.get_axis("move_down", "move_up")
	#else:
		## TODO: implement actual gravity-obedient jumping
		#input.y = Input.get_action_strength("jump") * 3
	print(velocity)
	move_and_slide()
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	twist_pivot.rotate_y(mouse_twist)
	pitch_pivot.rotate_x(mouse_pitch)
	
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90)
	)
	mouse_twist = 0.0
	mouse_pitch = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_twist = -event.relative.x * mouse_sensitivity
			mouse_pitch = -event.relative.y * mouse_sensitivity
