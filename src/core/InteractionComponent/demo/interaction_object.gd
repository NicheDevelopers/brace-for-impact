extends RigidBody3D

@onready var interaction_component: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction_component.interacted.connect(_on_interacted)

func _on_interacted(_body: Variant) -> void:
	self.rotate(Vector3.UP, 5)
