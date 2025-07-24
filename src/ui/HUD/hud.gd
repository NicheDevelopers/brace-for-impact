extends Control

@export var player: Player = null

@onready var health: HealthComponent = player.get_node("HealthComponent")
@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)

func _on_health_changed(new_value: float, _by_who: Variant) -> void:
	health_bar.value = new_value
	health_label.text = str(int(new_value))
