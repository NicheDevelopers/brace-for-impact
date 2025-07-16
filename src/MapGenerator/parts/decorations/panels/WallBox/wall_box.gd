extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var area: Area3D = $InteractionArea
## The user who is using the box right now
var user: Variant

func _ready() -> void:
	area.body_exited.connect(_on_interaction_area_body_exited)

func _on_interacted(body: Variant) -> void:
	if not user:
		user = body
		animation_player.play("open")
		return


func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body != user: return
	user = null
	animation_player.play("close")
	interaction_component.interaction_stopped.emit(body)
