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
@onready var animation_tree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var rig: Node3D = $Rig
@onready var skeleton: Skeleton3D = $Rig/Skeleton3D
@onready var hitbox: CollisionShape3D = $Hitbox
@onready var after_death_hitbox: CollisionShape3D = $AfterDeathHitbox
@onready var bone_simulator: PhysicalBoneSimulator3D = $Rig/Skeleton3D/PhysicalBoneSimulator3D
@onready var health: HealthComponent = $HealthComponent
@onready var hud: Control = $UI/HUD

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
@onready var jump_strength = 20.0

# Called when the node enters the scene tree for the first time.
var previous_input: Vector2 = Vector2.ZERO
var previous_tbob_depth: float = 0
var current_direction: Vector2 = Vector2.ZERO
var gravity = 55
var is_standing: bool = true

@onready var respawn_transform: Transform3D = transform
@onready var respawn_twist_transform: Transform3D = twist_pivot.transform
@onready var respawn_pitch_transform: Transform3D = pitch_pivot.transform
@onready var respawn_rig_transform: Transform3D = rig.transform

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

var log_velocity := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var initial_velocity_y = velocity.y
	if log_velocity: print("Initial Y velocity: ", initial_velocity_y)

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
	is_standing = true

	if log_velocity: print("after vars: ", velocity.y)

	direction.y = 0.0
	direction = direction.normalized()
	
	if Input.get_action_strength("crouch"):
		crouch_value = crouch_speed_multiplier
		is_standing = false
	elif Input.get_action_strength("sprint") and input[1] < 0.0:
		# if the player is moving forward and trying to sprint
		sprint_value = sprint_speed_multiplier

	if log_velocity: print("before move_toward: ", velocity.y)
	if log_velocity: print("ARG 1: ", direction * speed * crouch_value * sprint_value)
	if log_velocity: print("ARG 2: ", acceleration * delta)
	velocity = velocity.move_toward(direction * speed * crouch_value * sprint_value, acceleration * delta)
	if log_velocity: print("after move_toward: ", velocity.y)
	current_direction = map_direction(Vector2(velocity.x, velocity.z))
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#if velocity.length():
		#if abs(velocity.x) > speed or abs(velocity.z) > speed:
			#state_machine.travel("Sprint")
		#else:
			#if is_standing:
				#state_machine.travel("Walk")
			#else:
				#state_machine.travel("Crouch_Fwd")
	#else:
		#if is_standing:
			#state_machine.travel("Idle")
		#else:
			#state_machine.travel("Crouch_Idle")
	
	if no_gravity_mode:
		velocity.y = Input.get_axis("move_down", "move_up")
	else:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y += jump_strength
	
	var should_slow_down_by = 0
	var vel_before_slowdown: = velocity.y
	if log_velocity: print("Before slowdown: ", vel_before_slowdown)
	if not is_on_floor():
		velocity.y -= gravity * delta
		should_slow_down_by = gravity * delta
	var vel_after_slowdown: = velocity.y
	if log_velocity: print("After slowdown: ", vel_after_slowdown)
	if log_velocity: print("Slowed down by: ", vel_before_slowdown - vel_after_slowdown)
	if log_velocity: print("Should be: ", vel_before_slowdown - should_slow_down_by)
	if log_velocity: print("Is: ", velocity.y)
	if log_velocity: print("Error: ", (vel_before_slowdown - should_slow_down_by) - vel_after_slowdown)
	
	move_and_slide()
	
	animation_tree.update_animation(self)
	
	if Input.is_action_just_pressed("dev_free_cursor"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("dev_third_person_camera"):
		toggle_third_person_camera()
	
	if Input.is_action_just_pressed("dev_kill"):
		health.kill(self)
	
	if Input.is_action_just_pressed("dev_respawn"):
		respawn()
	
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
	
	var head_bone_index = skeleton.find_bone("DEF-head")
	var global_head_pos
	desired_height
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

	if log_velocity: print("Final Y velocity: ", velocity)
	if log_velocity: print("Delta from initial: ", velocity.y - initial_velocity_y)
	if log_velocity: print("------------------------------------")

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
	hitbox.disabled = true
	after_death_hitbox.disabled = false
	
	bone_simulator.physical_bones_start_simulation()
	
	await get_tree().create_timer(1.5).timeout
	
	respawn()

# Respawn the player, making them invincible for 0.5s to ensure
# physics adjusts to the reset transforms before it can be damaged again
func respawn():
	health.can_be_damaged = false
	health.restore(self)
	
	transform = respawn_transform
	twist_pivot.transform = respawn_twist_transform
	pitch_pivot.transform = respawn_pitch_transform
	rig.transform = respawn_rig_transform
	
	hitbox.disabled = false
	after_death_hitbox.disabled = true
	bone_simulator.physical_bones_stop_simulation()
	
	await get_tree().create_timer(0.5).timeout
	health.can_be_damaged = true

func toggle_third_person_camera():
	if third_person_camera:
		camera.position.z -= third_person_camera_distance
		third_person_camera = false
		hud.show_crosshair()
	else:
		camera.position.z += third_person_camera_distance
		third_person_camera = true
		hud.hide_crosshair()
