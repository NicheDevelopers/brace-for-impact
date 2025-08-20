extends AnimationTree

var is_on_floor: bool
#var just_jumped: bool
enum Movement {
	IDLE,
	WALKING,
	SPRINTING
}
var movement: Movement
var is_crouched: bool

func update_animation(player: Player):
	is_on_floor = player.is_on_floor()
	#if not is_zero_approx(velocity.y) and not is_on_floor():
	#	animation_tree["parameters/conditions/jump"] = true
	#else:
	#	animation_tree["parameters/conditions/jump"] = false
	
	var movement_velocity = Vector2(player.velocity.x, player.velocity.z)
	if movement_velocity.is_zero_approx():
		movement = Movement.IDLE
	else:
		if movement_velocity.length() > player.speed:
			movement = Movement.SPRINTING
		else:
			movement = Movement.WALKING
	
	is_crouched = not player.is_standing
