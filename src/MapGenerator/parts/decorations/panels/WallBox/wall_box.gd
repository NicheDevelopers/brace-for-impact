extends Interactable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum WallBoxState {
	OPEN,
	CLOSED
}

var state := WallBoxState.CLOSED

func _on_interacted(body: Variant) -> void:
	if state == WallBoxState.CLOSED:
		animation_player.play("open")
		state = WallBoxState.OPEN
		return
	animation_player.play("close")
	state = WallBoxState.CLOSED
