extends RigidBody3D

# TODO: replace this with a config value that's taken from the game settings
var mouse_sensitivity := 0.001
var mouse_twist := 0.0
var mouse_pitch := 0.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# placeholder variable which determines whether the player should obey the laws of gravity or not.
	# if there is no gravity, the player can jump, but not move up/down freely.
	# the reverse happens if there is no gravity.
	var no_gravity_mode := 0
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	if no_gravity_mode:
		input.y = Input.get_axis("move_down", "move_up")
	else:
		# TODO: implement actual gravity-obedient jumping
		input.y = Input.get_action_strength("jump") * 3
	if Input.get_action_strength("crouch"):
		input *= 0.5
	elif Input.get_action_strength("sprint"):
		input *= 2
	apply_central_force(twist_pivot.basis * input * 45000.0 * delta)
	
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
