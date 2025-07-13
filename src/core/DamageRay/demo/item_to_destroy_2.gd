extends RigidBody3D

@onready var label = $Label3D
@onready var health = $HealthComponent

func _ready() -> void:
	label.text = str(int(health.hp))

func _on_killed(by_who: Variant) -> void:
	queue_free()

func _health_changed(value: float, by_who: Variant) -> void:
	label.text = str(int(health.hp))
