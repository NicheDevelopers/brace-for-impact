extends CharacterBody3D

class_name Player

# TODO: replace this with a config value that's taken from the game settings
@export_group("Mouse")
@export var mouse_sensitivity := 0.001
@export var mouse_twist := 0.0
@export var mouse_pitch := 0.0

@export_group("Movement")
@export var speed = 4.0
@export var acceleration = 80.0
@export var sprint_speed_multiplier = 2.0
@export var crouch_speed_multiplier = 0.5
@export var acceleration_loss = 50.0

# placeholder variable which determines whether the player should obey the laws of gravity or not.
# if there is no gravity, the player can jump, but not move up/down freely.
# the reverse happens if there is no gravity.
@export var no_gravity_mode := 0

@export_group("Debug")
@export var third_person_camera := false
@export var third_person_camera_distance := 3.0

@onready var twist_pivot: Node3D = $TwistPivot
@onready var pitch_pivot: Node3D = $TwistPivot/PitchPivot
@onready var camera: Camera3D = $TwistPivot/PitchPivot/Camera3D
@onready var hand_point: Node3D = $TwistPivot/PitchPivot/Arm/HandPoint
@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var rig: Node3D = $Rig

# placeholder values correct for the default pill-shaped model
# TODO: change these values to be correct for the target player model
@onready var standing_height = twist_pivot.position.y
@onready var current_camera_height = twist_pivot.position.y
var t_bob = 0
var returning = 0
@export var standing_bobbing_depth = 0.15
@export var standing_bobbing_frequency = 5
@export var crouching_bobbing_depth = standing_bobbing_depth / 2
@export var crouching_bobbing_frequency = standing_bobbing_frequency / 2
@onready var crouching_height = standing_height - 0.85
@onready var desired_height = standing_height

# Called when the node enters the scene tree for the first time.
var previous_input: Vector2 = Vector2.ZERO
var previous_tbob_depth: float = 0
var current_direction: Vector2 = Vector2.ZERO
var gravity = 9.81 * 9.81

# TODO: move this functionality to equipment
var held_item_component: ItemComponent

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func map_direction(input):
	return Vector2(sign(input.x), sign(input.y))

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		

func _ready() -> void:
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if no_gravity_mode:
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	else:
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		
func _headbob(time, is_standing) -> Vector3:
	var position = Vector3.ZERO
	if is_standing:
		position.y = abs(sin(time * standing_bobbing_frequency)) * standing_bobbing_depth * -1
	else:
		position.y = abs(sin(time * crouching_bobbing_frequency)) * crouching_bobbing_depth * -1
	return position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if no_gravity_mode:
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	else:
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := twist_pivot.global_basis.z
	var right := twist_pivot.global_basis.x
	var direction := forward * input.y + right * input.x
	var crouch_value := 1.0
	var sprint_value := 1.0
	var is_standing := true
	
	direction.y = 0.0
	direction = direction.normalized()
	
	if Input.get_action_strength("crouch"):
		crouch_value = crouch_speed_multiplier
		is_standing = false
	elif Input.get_action_strength("sprint") and input[1] < 0.0:
		# if the player is moving forward and trying to sprint
		sprint_value = sprint_speed_multiplier

	velocity = velocity.move_toward(direction * speed * crouch_value * sprint_value, acceleration * delta)
	current_direction = map_direction(Vector2(velocity.x, velocity.z))
	
	if no_gravity_mode:
		velocity.y = Input.get_axis("move_down", "move_up")
	else:
		# TODO: implement actual gravity-obedient jumping
		velocity.y = Input.get_action_strength("jump") * 50 * int(is_on_floor())
		if velocity.y:
			if state_machine.get_current_node().substr(0, 4) != "Jump":
				state_machine.travel("Jump_Start")
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if velocity.length():
		if abs(velocity.x) > speed or abs(velocity.z) > speed:
			if state_machine.get_current_node() != "Sprint":
				state_machine.travel("Sprint")
		else:
			if is_standing:
				if state_machine.get_current_node() != "Walk":
					state_machine.travel("Walk")
			else:
				if state_machine.get_current_node() != "Crouch_Fwd":
					state_machine.travel("Crouch_Fwd")
	else:
		if is_standing:
			if state_machine.get_current_node() != "Idle":
				state_machine.travel("Idle")
		else:
			if state_machine.get_current_node() != "Crouch_Idle":
				state_machine.travel("Crouch_Idle")
	
	move_and_slide()
	
	if Input.is_action_just_pressed("dev_free_cursor"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("dev_third_person_camera"):
		if third_person_camera:
			camera.position.z -= third_person_camera_distance
			third_person_camera = false
		else:
			camera.position.z += third_person_camera_distance
			third_person_camera = true
		
	twist_pivot.rotate_y(mouse_twist)
	pitch_pivot.rotate_x(mouse_pitch)
	rig.rotate_y(mouse_twist)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89)
	)
	
	var current_headbob_depth = _headbob(t_bob, is_standing)
	
	if velocity.length():
		t_bob += delta * float(is_on_floor())
	else:
		if round_to_dec(current_headbob_depth.y, 2) != 0:
			if returning:
				t_bob += delta * float(is_on_floor()) * returning
			else:
				if previous_tbob_depth < current_headbob_depth.y:
					returning = 1
				else:
					returning = -1
		else:
			t_bob = 0
			returning = 0
			twist_pivot.transform.origin = Vector3.ZERO
			
	if not is_standing:
		desired_height = lerp(desired_height, crouching_height, 15 * delta)
	else:
		desired_height = lerp(desired_height, standing_height, 15 * delta)
		
	twist_pivot.transform.origin = Vector3(0, desired_height, 0) + current_headbob_depth
	previous_tbob_depth = current_headbob_depth.y
	mouse_twist = 0.0
	mouse_pitch = 0.0
	
	if Input.is_action_pressed("use_item"):
		if held_item_component != null:
			held_item_component.use(self)
	
	if Input.is_action_pressed("drop_item"):
		if held_item_component != null:
			held_item_component.drop(self)
	
	previous_input = input

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_twist = -event.relative.x * mouse_sensitivity
			mouse_pitch = -event.relative.y * mouse_sensitivity

func _on_item_picked_up(item_component: ItemComponent):
	held_item_component = item_component
	hand_point.add_child(item_component.parent)

func _item_drop():
	pass

func _on_killed(_by_who: Variant) -> void:
	queue_free()
